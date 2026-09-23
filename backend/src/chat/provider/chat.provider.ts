import { Colors } from "@backend/cash-flow/model/colors";
import { ChatPromptService } from "@backend/chat/chat.prompt.service";
import { ChatTimeframe } from "@backend/chat/model/api/chat.request.dto";
import { ChatHistory } from "@backend/chat/model/chat.history.model";
import { ChatOverview } from "@backend/chat/model/chat.overview.model";
import { ChatOverviewType } from "@backend/chat/model/chat.overview.type";
import { ChatProviderType } from "@backend/chat/model/chat.config.model";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { InternalServerErrorException, Logger } from "@nestjs/common";
import { ThrottlerException } from "@nestjs/throttler";

/** The kind of generation that is being requested from a provider. */
export type ChatModelType = "chat" | "overview";

/** A single role/parts block describing prompt content sent to an LLM. */
export interface ChatPromptContent {
  role: string;
  parts: Array<{ text: string }>;
}

/** Prompt content plus the real-to-generic identifier map used for de-identification. */
export interface ChatPromptResult {
  contents: ChatPromptContent[];
  idMap: Map<string, string>;
}

/**
 * Base class for every LLM provider. It centralizes all provider agnostic behavior
 *  (prompt orchestration, streaming over SSE, de-identification, chart colors, retries
 *  and overview persistence) so concrete providers only implement their transport layer.
 */
export abstract class ChatProvider {
  protected readonly logger: Logger;

  constructor(
    protected readonly sseService: SSEService,
    protected readonly promptBuilder: ChatPromptService,
    protected readonly user: User,
    protected readonly modelType: ChatModelType,
    providerType: ChatProviderType,
  ) {
    this.logger = new Logger(`service:chat:${providerType}`);
  }

  /** The resolved model identifier used for outgoing requests. */
  abstract get modelName(): string;

  /** Counts the tokens the given prompt content will consume for this provider. */
  abstract countTokens(contents: ChatPromptContent[]): Promise<number>;

  /** Generates the full text response for the given prompt using the concrete provider. */
  protected abstract generateContentRequest(contents: ChatPromptContent[]): Promise<string>;

  /** Streams incremental text chunks for the given prompt using the concrete provider. */
  protected abstract generateContentStreamRequest(contents: ChatPromptContent[]): AsyncIterable<string>;

  /** Counts tokens and logs how many a content set is going to use. */
  protected async logTokens(contents: ChatPromptContent[], messageType: string) {
    const tokens = await this.countTokens(contents);
    this.logger.debug(`Generating ${messageType} using ${this.modelName} with ${tokens} tokens.`);
  }

  /** Estimates a token count from the serialized prompt, used by providers without a counting endpoint. */
  protected estimateTokens(contents: ChatPromptContent[]): number {
    return Math.ceil(JSON.stringify(contents).length / 4);
  }

  /** Helper to apply dynamic string map replacement and chart color injection. */
  protected transformText(rawText: string, idMap: Map<string, string>): string {
    let transformed = rawText;
    const sortedEntries = Array.from(idMap.entries()).sort((a, b) => b[1].length - a[1].length);
    for (const [realName, genericId] of sortedEntries) transformed = transformed.replaceAll(genericId, realName);
    return this.injectChartColors(transformed);
  }

  /** Determines if the given error indicates the provider is temporarily overloaded. */
  protected isOverloadedError(error: any): boolean {
    return Boolean(error?.code === 503 || error?.status === 503 || error?.status === "UNAVAILABLE" || error?.message?.includes("high demand"));
  }

  /** Determines if the given error indicates the caller exceeded their request quota. */
  protected isQuotaError(error: any): boolean {
    return Boolean(
      error?.code === 429 || error?.status === 429 || error?.message?.includes("You exceeded your current quota") || error?.message?.includes("429"),
    );
  }

  /** Extracts a user-facing message from provider specific error shapes when possible. */
  protected extractErrorMessage(error: any): string | undefined {
    if (error?.error?.message) return error.error.message;
    if (typeof error?.message === "string" && error.message.trim().startsWith("{")) {
      try {
        return JSON.parse(error.message)?.error?.message;
      } catch {
        /* not valid JSON, fall through and rethrow the original error */
      }
    }
    return undefined;
  }

  /** Executes a non-streamed generation with overload retries and shared error mapping. */
  protected async generateContent(contents: ChatPromptContent[], idMap: Map<string, string>, maxRetries = 3): Promise<string> {
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        const response = await this.generateContentRequest(contents);
        const aiText = this.transformText(response ?? "", idMap);

        if (!aiText) throw new InternalServerErrorException("Failed to process request to LLM.");
        return aiText;
      } catch (e: any) {
        // Check if the error is a temporary 503 / High Demand issue
        const isOverloaded = this.isOverloadedError(e);

        if (isOverloaded && attempt < maxRetries) {
          const delayMs = attempt * 5000; // Exponential backoff
          this.logger.warn(`Model overloaded (503). Retrying attempt ${attempt}/${maxRetries} in ${delayMs}ms...`);
          await new Promise((resolve) => setTimeout(resolve, delayMs));
          continue; // Loop again
        }

        // Retries exhausted while the model is still overloaded: fall through to the generic failure below
        if (isOverloaded) break;

        // If it's a quota error, surface a throttling exception to the caller
        if (this.isQuotaError(e)) throw new ThrottlerException("You have exceeded your request quota. Try again later.");

        const message = this.extractErrorMessage(e);
        if (message) throw message;
        throw e;
      }
    }

    throw new InternalServerErrorException("Failed to generate content: retry limit reached or invalid configuration.");
  }

  /**
   * Generates chat responses for user requests.
   * @param stream If we should send the data over SSE to update the user on the fly instead of waiting for it to be done.
   */
  async generateChatContent(chat: ChatHistory, timeframe: ChatTimeframe, allowCharts: boolean, stream = true): Promise<string> {
    try {
      const { contents, idMap } = await this.promptBuilder.buildChatPrompt(this.user, timeframe, allowCharts);
      await this.logTokens(contents, "chat response");

      let rawAccumulatedText = "";
      for await (const chunkText of this.generateContentStreamRequest(contents)) {
        if (chunkText) {
          rawAccumulatedText += chunkText;
          chat.text = this.transformText(rawAccumulatedText, idMap);
          if (stream) {
            chat.isThinking = false;
            this.sseService.sendToUser(this.user, SSEEventType.CHAT, chat);
          }
        }
      }

      return chat.text;
    } catch (e) {
      chat.isThinking = false;
      chat.text = (e as Error).message;
      await chat.update();
      this.sseService.sendToUser(this.user, SSEEventType.CHAT, chat);
      throw e;
    } finally {
      chat.isThinking = false;
      await chat.update();
      this.sseService.sendToUser(this.user, SSEEventType.CHAT, chat);
    }
  }

  /** Single consolidated overview generator that routes prompt building by type. */
  async generateOverview(overviewType: ChatOverviewType): Promise<ChatOverview> {
    const promptResult =
      overviewType === ChatOverviewType.holdings
        ? await this.promptBuilder.buildHoldingsOverviewPrompt(this.user)
        : await this.promptBuilder.buildDailyOverviewPrompt(this.user);

    await this.logTokens(promptResult.contents, `${overviewType} overview`);
    const text = await this.generateContent(promptResult.contents, promptResult.idMap);
    return this.saveOverview(text, overviewType);
  }

  /** Helper to upsert a chat overview by type. */
  private async saveOverview(text: string, type: ChatOverviewType): Promise<ChatOverview> {
    let status = await ChatOverview.findOne({ where: { user: { id: this.user.id }, type } });
    if (status) {
      status.text = text;
      status.time = new Date();
      await status.update();
    } else {
      status = await new ChatOverview(this.user, text, type).insert();
    }
    return status;
  }

  /** Helper function that allows us to inject colors for charts based on our supported backend colors */
  protected injectChartColors(text: string): string {
    const chartRegex = /```chart\s*([\s\S]*?)\s*```/g;
    return text.replace(chartRegex, (match, jsonString) => {
      try {
        const chartData = JSON.parse(jsonString.trim());
        if (chartData && chartData.type === "line" && Array.isArray(chartData.series)) {
          chartData.series = chartData.series.map((series: any) => ({
            ...series,
            color: Colors.getColorForFeature(series.label || "Default"),
          }));
        } else if (chartData && chartData.type === "pie" && chartData.data) {
          const colorMapping: Record<string, string> = {};
          for (const key of Object.keys(chartData.data)) {
            colorMapping[key] = Colors.getColorForFeature(key);
          }
          chartData.colors = colorMapping;
        }
        return `\`\`\`chart\n${JSON.stringify(chartData, null, 2)}\n\`\`\``;
      } catch (e) {
        return match;
      }
    });
  }
}
