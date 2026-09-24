import { ChatPromptService } from "@backend/chat/chat.prompt.service";
import { ChatModelType, ChatPromptContent, ChatProvider } from "@backend/chat/provider/chat.provider";
import { OpenCodeGateway } from "@backend/chat/model/chat.config.model";
import { Configuration } from "@backend/config/core";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { BadRequestException } from "@nestjs/common";
import { createHash } from "crypto";

/** A message in the OpenAI compatible chat completions format. */
interface OpenCodeMessage {
  role: string;
  content: string;
}

/** Gateway base URLs. These are stable and only change alongside a code change. */
const OPEN_CODE_BASE_URLS: Record<OpenCodeGateway, string> = {
  "opencode-zen": "https://opencode.ai/zen/v1",
  "opencode-go": "https://opencode.ai/zen/go/v1",
};

/**
 * A chat provider for the OpenCode gateways (Zen & Go). Both expose an OpenAI compatible
 *  chat completions API, so a single implementation is reused and parameterized by gateway.
 */
export class OpenCodeChatProvider extends ChatProvider {
  private readonly type: string;
  private readonly apiKey: string;
  private readonly sessionId: string;

  constructor(
    sseService: SSEService,
    promptBuilder: ChatPromptService,
    user: User,
    modelType: ChatModelType,
    private readonly gateway: OpenCodeGateway,
  ) {
    super(sseService, promptBuilder, user, modelType, gateway);

    const config = Configuration.server.prompt.openCode;
    if (!config.key) throw new BadRequestException("No API key configured. Please set an API key in settings");

    this.type = modelType === "overview" ? config.overviewModel : config.chatModel;
    this.apiKey = config.key;

    // The gateway expects a stable session ID per conversation so it can optimize routing
    // and prompt caching. We hash the internal user id so we do not disclose it to a third party.
    this.sessionId = createHash("sha256").update(`${user.id}:${modelType}`).digest("hex");
  }

  get modelName(): string {
    return this.type;
  }

  /** The OpenCode gateway has no token counting endpoint, so we estimate from the payload. */
  async countTokens(contents: ChatPromptContent[]): Promise<number> {
    return this.estimateTokens(contents);
  }

  /** Executes a non-streamed chat completion and returns the assistant message. */
  protected async generateContentRequest(contents: ChatPromptContent[]): Promise<string> {
    const response = await this.request(contents, false);
    const json = await response.json();
    return json?.choices?.[0]?.message?.content ?? "";
  }

  /** Streams a chat completion using Server-Sent Events. */
  protected async *generateContentStreamRequest(contents: ChatPromptContent[]): AsyncIterable<string> {
    const response = await this.request(contents, true);
    if (!response.body) return;

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let buffer = "";

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      buffer += decoder.decode(value, { stream: true });
      const lines = buffer.split("\n");
      buffer = lines.pop()!;

      for (const line of lines) {
        const trimmed = line.trim();
        if (!trimmed.startsWith("data:")) continue;

        const data = trimmed.slice("data:".length).trim();
        if (data === "[DONE]") return;

        try {
          const parsed = JSON.parse(data);
          const text = parsed?.choices?.[0]?.delta?.content;
          if (text) yield text;
        } catch (e) {
          /* ignore malformed keep-alive chunks */
        }
      }
    }
  }

  /** Sends a chat completions request to the configured gateway, throwing on non-OK responses. */
  private async request(contents: ChatPromptContent[], stream: boolean): Promise<Response> {
    const response = await fetch(`${OPEN_CODE_BASE_URLS[this.gateway]}/chat/completions`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${this.apiKey}`,
        "User-Agent": "sprout/1.0",
        "x-opencode-session": this.sessionId,
      },
      body: JSON.stringify({ model: this.type, messages: this.toMessages(contents), stream }),
    });

    if (!response.ok) {
      const text = await response.text();
      let message = text;
      try {
        message = JSON.parse(text)?.error?.message ?? text;
      } catch (e) {
        /* keep the raw body when it is not JSON */
      }

      const error = new Error(message || `OpenCode request failed with status ${response.status}`) as Error & { status?: number; code?: number };
      error.status = response.status;
      error.code = response.status;
      throw error;
    }

    return response;
  }

  /** Converts our generic prompt content into OpenAI compatible chat messages. */
  private toMessages(contents: ChatPromptContent[]): OpenCodeMessage[] {
    return contents.map((content) => ({
      role: content.role === "model" ? "assistant" : content.role,
      content: content.parts.map((part) => part.text).join("\n"),
    }));
  }
}
