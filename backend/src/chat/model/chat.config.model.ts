import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";

/** Config related to gemini */
export class GeminiConfig {
  @ConfigurationMetadata.assign({ comment: "The model gemini should use when performing prompt requests." })
  model: string = "gemini-3-flash-preview";

  @ConfigurationMetadata.assign({ comment: "A global key to use to authenticate to gemini. If given, users will not be able to provide their own." })
  key?: string;
}

/** Contains LLM configuration options */
export class ChatConfig {
  @ConfigurationMetadata.assign({
    comment: "The number of chats that should be included in context and kept in the db. We will remove anything over this number.",
  })
  maxChatHistory: number = 10;

  @ConfigurationMetadata.assign({ comment: "What LLM source should be used.", restrictedValues: ["gemini"] })
  type: "gemini" = "gemini";

  @ConfigurationMetadata.assign({ comment: "Configuration for using Gemini." })
  gemini = new GeminiConfig();

  /** Returns if an API key is globally configured. */
  get hasChatKey() {
    const key = this[this.type].key;
    return key != null && key !== "";
  }
}
