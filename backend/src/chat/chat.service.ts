import { Colors } from "@backend/cash-flow/model/colors";
import { ChatPromptService } from "@backend/chat/chat.prompt.service";
import { ChatTimeframe } from "@backend/chat/model/api/chat.request.dto";
import { ChatHistory } from "@backend/chat/model/chat.history.model";
import { ChatOverview } from "@backend/chat/model/chat.overview.model";
import { ChatOverviewType } from "@backend/chat/model/chat.overview.type";
import { Configuration } from "@backend/config/core";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { ApiError, ContentListUnion, GoogleGenAI } from "@google/genai";
import { BadRequestException, Injectable, InternalServerErrorException, Logger } from "@nestjs/common";
import { ThrottlerException } from "@nestjs/throttler";

/** A service that provides reusable functions to LLM prompting capabilities */
@Injectable()
export class ChatService {
  private readonly logger = new Logger("service:chat");

  constructor(
    private readonly sseService: SSEService,
    private readonly promptBuilder: ChatPromptService,
  ) {}

  /** Gets the model for the given user's LLM configuration */
  async getModel(user: User) {
    if (Configuration.server.prompt.type === "gemini") {
      const apiKey = Configuration.server.prompt.gemini.key;
      if (!apiKey) throw new BadRequestException("No API key configured. Please set an API key in settings");

      const aiModel = new GoogleGenAI({ apiKey }).models;
      const type = Configuration.server.prompt.gemini.model;

      /** Logs how many tokens a content set is going to use */
      const logTokens = async (contents: ContentListUnion, messageType: string) => {
        const tokens = await countTokens(contents);
        this.logger.debug(`Generating ${messageType} using ${type} with ${tokens} tokens.`);
      };

      /** Counts the number of tokens the given content will use for our model. */
      const countTokens = async (contents: ContentListUnion) => {
        try {
          const result = await aiModel.countTokens({ model: type, contents });
          return result.totalTokens ?? 0;
        } catch (e) {
          return 0;
        }
      };

      /** Helper to apply dynamic string map replacement and chart color injection */
      const transformText = (rawText: string, idMap: Map<string, string>): string => {
        let transformed = rawText;
        const sortedEntries = Array.from(idMap.entries()).sort((a, b) => b[1].length - a[1].length);
        for (const [realName, genericId] of sortedEntries) transformed = transformed.replaceAll(genericId, realName);
        return this.injectChartColors(transformed);
      };

      /** Executes LLM generation for standard non-streamed responses (e.g. overviews). */
      const generateContent = async (contents: ContentListUnion, idMap: Map<string, string>, maxRetries = 3) => {
        let attempt = 0;

        while (attempt < maxRetries) {
          try {
            const response = await aiModel.generateContent({ model: type, contents });
            const aiText = transformText(response.text ?? "", idMap);

            if (!aiText) throw new InternalServerErrorException("Failed to to process request to LLM.");
            return aiText;
          } catch (e: any) {
            attempt++;

            // Check if the error is a temporary 503 / High Demand issue
            const isOverloaded = e?.code === 503 || e?.status === "UNAVAILABLE" || e?.message?.includes("high demand");

            if (isOverloaded && attempt < maxRetries) {
              const delayMs = attempt * 5000; // Exponential backoff
              this.logger.warn(`Model overloaded (503). Retrying attempt ${attempt}/${maxRetries} in ${delayMs}ms...`);
              await new Promise((resolve) => setTimeout(resolve, delayMs));
              continue; // Loop again
            }

            // If we exhaust retries or it's a different error, throw normally
            if (e?.message?.includes("You exceeded your current quota") || e?.message?.includes("429"))
              throw new ThrottlerException("You have exceeded your request quota. Try again later.");

            // Safely attempt to parse JSON errors, otherwise fall through
            try {
              if (e?.message && e.message.trim().startsWith("{")) {
                throw JSON.parse(e.message)?.error as ApiError;
              }
            } catch (parseError) {
              /* ignore parse error */
            }

            const err = e?.error as ApiError | undefined;
            if (err?.message) throw err.message;
            throw e;
          }
        }

        // Fallback
        throw new InternalServerErrorException("Failed to generate content: retry limit reached or invalid configuration.");
      };

      /**
       * Generates chat responses for user requests.
       * @param stream If we should send the data over SSE to update the user on the fly instead of waiting for it to be done.
       */
      const generateChatContent = async (chat: ChatHistory, timeframe: ChatTimeframe, allowCharts: boolean, stream = true) => {
        try {
          const { contents, idMap } = await this.promptBuilder.buildChatPrompt(user, timeframe, allowCharts);
          await logTokens(contents, "chat response");

          const responseStream = await aiModel.generateContentStream({ model: type, contents });
          let rawAccumulatedText = "";

          for await (const chunk of responseStream) {
            const chunkText = chunk.text;
            if (chunkText) {
              rawAccumulatedText += chunkText;
              chat.text = transformText(rawAccumulatedText, idMap);
              if (stream) {
                chat.isThinking = false;
                this.sseService.sendToUser(user, SSEEventType.CHAT, chat);
              }
            }
          }

          return chat.text;
        } catch (e) {
          chat.isThinking = false;
          chat.text = (e as Error).message;
          await chat.update();
          this.sseService.sendToUser(user, SSEEventType.CHAT, chat);
          throw e;
        } finally {
          chat.isThinking = false;
          await chat.update();
          this.sseService.sendToUser(user, SSEEventType.CHAT, chat);
        }
      };

      /** Helper to upsert a chat overview by type. */
      const saveOverview = async (text: string, type: ChatOverviewType) => {
        let status = await ChatOverview.findOne({ where: { user: { id: user.id }, type } });
        if (status) {
          status.text = text;
          status.time = new Date();
          await status.update();
        } else {
          status = await new ChatOverview(user, text, type).insert();
        }
        return status;
      };

      /** Single consolidated overview generator that routes prompt building by type. */
      const generateOverview = async (overviewType: ChatOverviewType) => {
        const promptResult =
          overviewType === ChatOverviewType.holdings
            ? await this.promptBuilder.buildHoldingsOverviewPrompt(user)
            : await this.promptBuilder.buildDailyOverviewPrompt(user);

        await logTokens(promptResult.contents, `${overviewType} overview`);
        const text = await generateContent(promptResult.contents, promptResult.idMap);
        return saveOverview(text, overviewType);
      };

      return {
        type,
        countTokens,
        generateChatContent,
        generateOverview,
      };
    } else {
      throw new InternalServerErrorException("Invalid LLM model configured");
    }
  }

  /** Helper function that allows us to inject colors for charts based on our supported backend colors */
  private injectChartColors(text: string): string {
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
