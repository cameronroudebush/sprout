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

      /** Executes LLM generation and maps generic IDs back to real names. */
      const generateContent = async (contents: ContentListUnion, idMap: Map<string, string>) => {
        try {
          const response = await aiModel.generateContent({ model: type, contents });
          let aiText = response.text ?? "";
          const sortedEntries = Array.from(idMap.entries()).sort((a, b) => b[1].length - a[1].length);
          for (const [realName, genericId] of sortedEntries) aiText = aiText.replaceAll(genericId, realName);
          if (!aiText) throw new InternalServerErrorException("Failed to to process request to LLM.");
          return aiText;
        } catch (e: any) {
          if (e?.message?.includes("You exceeded your current quota") || e?.message?.includes("429"))
            throw new ThrottlerException("You have exceeded your request quota. Try again later.");

          if (e?.message) throw JSON.parse(e.message)?.error as ApiError;
          const err = e?.error as ApiError | undefined;
          if (err?.message) throw err.message;
          throw e;
        }
      };

      /** Generates chat responses for user requests. */
      const generateChatContent = async (chat: ChatHistory, timeframe: ChatTimeframe) => {
        try {
          const { contents, idMap } = await this.promptBuilder.buildChatPrompt(user, timeframe);
          await logTokens(contents, "chat response");
          const aiText = await generateContent(contents, idMap);
          chat.text = aiText;
          return aiText;
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
}
