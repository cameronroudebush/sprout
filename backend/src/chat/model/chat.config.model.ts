import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";

/** Contains LLM configuration options */
export class ChatConfig {
  @ConfigurationMetadata.assign({ comment: "The model gemini should use when performing prompt requests." })
  geminiModel: string = "gemini-3-flash-preview";

  @ConfigurationMetadata.assign({
    comment: "The number of chats that should be included in context and kept in the db. We will remove anything over this number.",
  })
  maxChatHistory: number = 10;
}
