import { ChatPromptService } from "@backend/chat/chat.prompt.service";
import { ChatModelType, ChatProvider } from "@backend/chat/provider/chat.provider";
import { GeminiChatProvider } from "@backend/chat/provider/gemini.chat.provider";
import { OpenCodeChatProvider } from "@backend/chat/provider/open-code.chat.provider";
import { Configuration } from "@backend/config/core";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { Injectable, InternalServerErrorException } from "@nestjs/common";

/** A service that provides reusable functions to LLM prompting capabilities */
@Injectable()
export class ChatService {
  constructor(
    private readonly sseService: SSEService,
    private readonly promptBuilder: ChatPromptService,
  ) {}

  /**
   * Gets the provider for the given user's LLM configuration.
   * @param modelType The type of model we want to use based on the configuration. Allows more complex
   *  models to be used for chat while overviews can use more basic ones, if configured so. By default, they use the same.
   */
  async getModel(user: User, modelType: ChatModelType = "chat"): Promise<ChatProvider> {
    const prompt = Configuration.server.prompt;

    switch (prompt.type) {
      case "gemini":
        return new GeminiChatProvider(this.sseService, this.promptBuilder, user, modelType);
      case "opencode-zen":
      case "opencode-go":
        return new OpenCodeChatProvider(this.sseService, this.promptBuilder, user, modelType, prompt.type);
      default:
        throw new InternalServerErrorException("Invalid LLM model configured");
    }
  }
}
