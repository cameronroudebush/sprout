import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";

/** The LLM providers that can power the chat capabilities. */
export type ChatProviderType = "gemini" | "opencode-zen" | "opencode-go";

/** The OpenCode gateways Sprout supports. The type selects the gateway URL, it is not user configurable. */
export type OpenCodeGateway = Extract<ChatProviderType, "opencode-zen" | "opencode-go">;

/** Config related to gemini */
export class GeminiConfig {
  @ConfigurationMetadata.assign({ comment: "The model gemini should use for conversations." })
  chatModel: string = "gemini-flash-latest";

  @ConfigurationMetadata.assign({ comment: "The model gemini should use to generate overviews." })
  overviewModel: string = "gemini-flash-lite-latest";

  @ConfigurationMetadata.assign({ comment: "A global key to use to authenticate to gemini." })
  key?: string;
}

/**
 * Config shared by the OpenCode gateways (Zen & Go). Both expose an OpenAI compatible
 *  `/chat/completions` endpoint and only differ by their base URL, which is derived from
 *  the configured type rather than being user configurable.
 */
export class OpenCodeConfig {
  @ConfigurationMetadata.assign({ comment: "The model OpenCode should use for conversations." })
  chatModel: string = "glm-5.3-flash";

  @ConfigurationMetadata.assign({ comment: "The model OpenCode should use to generate overviews." })
  overviewModel: string = "glm-5.3-flash";

  @ConfigurationMetadata.assign({ comment: "A global key to use to authenticate to OpenCode." })
  key?: string;
}

/** Contains LLM configuration options */
export class ChatConfig {
  @ConfigurationMetadata.assign({
    comment: "The number of chats that should be included in context and kept in the db. We will remove anything over this number.",
  })
  maxChatHistory: number = 10;

  @ConfigurationMetadata.assign({ comment: "What LLM source should be used.", restrictedValues: ["gemini", "opencode-zen", "opencode-go"] })
  type: ChatProviderType = "gemini";

  @ConfigurationMetadata.assign({ comment: "Configuration for using Gemini." })
  gemini = new GeminiConfig();

  @ConfigurationMetadata.assign({ comment: "Configuration for using the OpenCode gateways (https://opencode.ai/zen)." })
  openCode = new OpenCodeConfig();

  /** Resolves the configuration block for the currently selected provider. */
  get provider(): GeminiConfig | OpenCodeConfig | undefined {
    switch (this.type) {
      case "gemini":
        return this.gemini;
      case "opencode-zen":
      case "opencode-go":
        return this.openCode;
      default:
        return undefined;
    }
  }

  /** Returns if AI chat is enabled. */
  get enabled() {
    const key = this.provider?.key;
    return key != null && key !== "";
  }
}
