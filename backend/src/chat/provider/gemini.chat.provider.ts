import { ChatPromptService } from "@backend/chat/chat.prompt.service";
import { ChatModelType, ChatPromptContent, ChatProvider } from "@backend/chat/provider/chat.provider";
import { Configuration } from "@backend/config/core";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { ContentListUnion, GoogleGenAI } from "@google/genai";
import { BadRequestException } from "@nestjs/common";

/** A chat provider backed by Google's Gemini models. */
export class GeminiChatProvider extends ChatProvider {
  private readonly models;
  private readonly type: string;

  constructor(sseService: SSEService, promptBuilder: ChatPromptService, user: User, modelType: ChatModelType) {
    super(sseService, promptBuilder, user, modelType, "gemini");

    const config = Configuration.server.prompt.gemini;
    if (!config.key) throw new BadRequestException("No API key configured. Please set an API key in settings");

    this.models = new GoogleGenAI({ apiKey: config.key }).models;
    this.type = modelType === "overview" ? config.overviewModel : config.chatModel;
  }

  get modelName(): string {
    return this.type;
  }

  /** Counts the number of tokens the given content will use for our model. */
  async countTokens(contents: ChatPromptContent[]): Promise<number> {
    try {
      const result = await this.models.countTokens({ model: this.type, contents: contents as ContentListUnion });
      return result.totalTokens ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /** Executes LLM generation for standard non-streamed responses (e.g. overviews). */
  protected async generateContentRequest(contents: ChatPromptContent[]): Promise<string> {
    const response = await this.models.generateContent({ model: this.type, contents: contents as ContentListUnion });
    return response.text ?? "";
  }

  /** Streams the model response chunk by chunk. */
  protected async *generateContentStreamRequest(contents: ChatPromptContent[]): AsyncIterable<string> {
    const responseStream = await this.models.generateContentStream({ model: this.type, contents: contents as ContentListUnion });
    for await (const chunk of responseStream) {
      if (chunk.text) yield chunk.text;
    }
  }
}
