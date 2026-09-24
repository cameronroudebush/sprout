import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { ChatPromptService } from "@backend/chat/chat.prompt.service.js";
import { Colors } from "@backend/cash-flow/model/colors.js";
import { ChatTimeframe } from "@backend/chat/model/api/chat.request.dto.js";
import { ChatHistory } from "@backend/chat/model/chat.history.model.js";
import { ChatOverview } from "@backend/chat/model/chat.overview.model.js";
import { ChatOverviewType } from "@backend/chat/model/chat.overview.type.js";
import { ChatModelType, ChatPromptContent, ChatProvider } from "@backend/chat/provider/chat.provider.js";
import { ChatProviderType } from "@backend/chat/model/chat.config.model.js";
import { SSEEventType } from "@backend/sse/model/event.model.js";
import { SSEService } from "@backend/sse/sse.service.js";
import { TestEntities } from "@backend/test/entities.js";
import { InternalServerErrorException } from "@nestjs/common";
import { ThrottlerException } from "@nestjs/throttler";
import { Mocked } from "vitest";

/** Minimal concrete provider used to exercise the shared behavior of the abstract base. */
class TestChatProvider extends ChatProvider {
  countTokensMock = vi.fn<() => Promise<number>>().mockResolvedValue(7);
  contentMock = vi.fn<() => Promise<string>>().mockResolvedValue("Hello Acc_0");
  streamChunks: string[] = [];
  streamError: unknown;

  constructor(
    sseService: SSEService,
    promptBuilder: ChatPromptService,
    user: typeof TestEntities.user,
    modelType: ChatModelType = "chat",
    providerType: ChatProviderType = "gemini",
  ) {
    super(sseService, promptBuilder, user, modelType, providerType);
  }

  get modelName(): string {
    return "test-model";
  }

  countTokens(_contents?: ChatPromptContent[]): Promise<number> {
    return this.countTokensMock();
  }

  protected generateContentRequest(): Promise<string> {
    return this.contentMock();
  }

  protected async *generateContentStreamRequest(): AsyncIterable<string> {
    if (this.streamError) throw this.streamError;
    for (const chunk of this.streamChunks) yield chunk;
  }

  // Exposes protected members so their branches can be asserted directly.
  public runTransform(text: string, idMap: Map<string, string>) {
    return this.transformText(text, idMap);
  }
  public runInject(text: string) {
    return this.injectChartColors(text);
  }
  public runEstimate(contents: ChatPromptContent[]) {
    return this.estimateTokens(contents);
  }
  public runExtract(error: unknown) {
    return this.extractErrorMessage(error);
  }
  public runIsOverloaded(error: unknown) {
    return this.isOverloadedError(error);
  }
  public runIsQuota(error: unknown) {
    return this.isQuotaError(error);
  }
  public get loggerContext(): string | undefined {
    return (this.logger as unknown as { context?: string }).context;
  }
  public runGenerate(contents: ChatPromptContent[], idMap: Map<string, string>, retries?: number) {
    return this.generateContent(contents, idMap, retries);
  }
}

describe("ChatProvider", () => {
  let provider: TestChatProvider;
  let sseService: Mocked<SSEService>;
  let promptBuilder: Mocked<ChatPromptService>;
  const user = TestEntities.user;
  const contents: ChatPromptContent[] = [{ role: "user", parts: [{ text: "prompt" }] }];

  beforeEach(() => {
    vi.restoreAllMocks();

    sseService = { sendToUser: vi.fn() } as unknown as Mocked<SSEService>;
    promptBuilder = {
      buildChatPrompt: vi.fn().mockResolvedValue({ contents, idMap: new Map([["User Checking", "Acc_0"]]) }),
      buildDailyOverviewPrompt: vi.fn().mockResolvedValue({ contents, idMap: new Map() }),
      buildHoldingsOverviewPrompt: vi.fn().mockResolvedValue({ contents, idMap: new Map() }),
    } as unknown as Mocked<ChatPromptService>;

    provider = new TestChatProvider(sseService, promptBuilder, user);
  });

  it("should expose the model name and delegate token counting", async () => {
    expect(provider.modelName).toBe("test-model");
    expect(provider.loggerContext).toBe("service:chat:gemini");
    await expect(provider.countTokens(contents)).resolves.toBe(7);
    expect(provider.runEstimate(contents)).toBeGreaterThan(0);
  });

  it("should run the shared error classifiers", () => {
    expect(provider.runIsOverloaded({ code: 503 })).toBe(true);
    expect(provider.runIsOverloaded({ status: 503 })).toBe(true);
    expect(provider.runIsOverloaded({ status: "UNAVAILABLE" })).toBe(true);
    expect(provider.runIsOverloaded({ message: "high demand" })).toBe(true);
    expect(provider.runIsOverloaded({})).toBe(false);

    expect(provider.runIsQuota({ code: 429 })).toBe(true);
    expect(provider.runIsQuota({ status: 429 })).toBe(true);
    expect(provider.runIsQuota({ message: "You exceeded your current quota" })).toBe(true);
    expect(provider.runIsQuota({ message: "error 429" })).toBe(true);
    expect(provider.runIsQuota({})).toBe(false);
  });

  it("should extract messages from the various provider error shapes", () => {
    expect(provider.runExtract({ error: { message: "Direct error" } })).toBe("Direct error");
    expect(provider.runExtract(new Error('{"error":{"message":"API Error Msg"}}'))).toBe("API Error Msg");
    expect(provider.runExtract(new Error("{ invalid json"))).toBeUndefined();
    expect(provider.runExtract(new Error("plain"))).toBeUndefined();
    expect(provider.runExtract(undefined)).toBeUndefined();
  });

  it("should transform text and inject chart colors", () => {
    const transformed = provider.runTransform(
      "Hello Acc_0 and T_0",
      new Map([
        ["User Checking", "Acc_0"],
        ["Transaction", "T_0"],
      ]),
    );
    expect(transformed).toBe("Hello User Checking and Transaction");

    const lineChart = '```chart\n{"type":"line","series":[{"label":"Checking"}]}\n```';
    const coloredLineChart = provider.runInject(lineChart);
    expect(coloredLineChart).toContain('"color"');
    expect(coloredLineChart).not.toContain(Colors.chatCardBackgroundColor);

    const unlabeledLine = '```chart\n{"type":"line","series":[{}]}\n```';
    expect(provider.runInject(unlabeledLine)).toContain('"color"');

    const pieChart = '```chart\n{"type":"pie","data":{"Dining":100}}\n```';
    expect(provider.runInject(pieChart)).toContain('"colors"');

    const otherChart = '```chart\n{"type":"bar","data":{}}\n```';
    expect(provider.runInject(otherChart)).toContain('"type": "bar"');

    const invalid = "```chart\n{invalid}\n```";
    expect(provider.runInject(invalid)).toBe(invalid);
  });

  it("should generate and transform non-streamed content", async () => {
    await expect(provider.runGenerate(contents, new Map([["User Checking", "Acc_0"]]))).resolves.toBe("Hello User Checking");
  });

  it("should throw when the provider returns empty content", async () => {
    provider.contentMock.mockResolvedValue("");
    await expect(provider.runGenerate(contents, new Map())).rejects.toThrow(InternalServerErrorException);
  });

  it("should tolerate an undefined provider response", async () => {
    provider.contentMock.mockResolvedValueOnce(undefined as unknown as string);
    await expect(provider.runGenerate(contents, new Map())).rejects.toThrow(InternalServerErrorException);
  });

  it("should surface an extracted provider error message", async () => {
    provider.contentMock.mockRejectedValueOnce({ error: { message: "provider boom" } });
    await expect(provider.runGenerate(contents, new Map())).rejects.toThrow("provider boom");
  });

  it("should retry an overloaded provider and eventually succeed", async () => {
    vi.useFakeTimers();
    try {
      provider.contentMock.mockRejectedValueOnce({ code: 503, message: "high demand" }).mockResolvedValueOnce("Recovered");
      const promise = provider.runGenerate(contents, new Map());
      await vi.advanceTimersByTimeAsync(10000);
      await expect(promise).resolves.toBe("Recovered");
    } finally {
      vi.useRealTimers();
    }
  });

  it("should surface a generic failure when the provider stays overloaded", async () => {
    vi.useFakeTimers();
    try {
      provider.contentMock.mockRejectedValue({ code: 503, message: "high demand" });
      const promise = provider.runGenerate(contents, new Map());
      const rejection = expect(promise).rejects.toThrow("Failed to generate content: retry limit reached or invalid configuration.");
      await vi.advanceTimersByTimeAsync(30000);
      await rejection;
    } finally {
      vi.useRealTimers();
    }
  });

  it("should throw a ThrottlerException when the provider reports a quota error", async () => {
    provider.contentMock.mockRejectedValue(new Error("429 Too Many Requests"));
    await expect(provider.runGenerate(contents, new Map())).rejects.toThrow(ThrottlerException);
  });

  it("should rethrow unknown provider errors untouched", async () => {
    provider.contentMock.mockRejectedValue(new Error("plain failure"));
    await expect(provider.runGenerate(contents, new Map())).rejects.toThrow("plain failure");
  });

  it("should stream chat content and notify over SSE", async () => {
    provider.streamChunks = ["Hello ", "Acc_0"];

    const chat = new ChatHistory(user, "question", "user");
    chat.update = vi.fn().mockResolvedValue(chat);

    await expect(provider.generateChatContent(chat, ChatTimeframe.threeMonths, false, true)).resolves.toBe("Hello User Checking");
    expect(chat.text).toBe("Hello User Checking");
    expect(chat.model).toBe("test-model");
    expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.CHAT, chat);
  });

  it("should skip empty chunks and avoid per-chunk SSE when not streaming", async () => {
    provider.streamChunks = ["", "chunk"];

    const chat = new ChatHistory(user, "question", "user");
    chat.update = vi.fn().mockResolvedValue(chat);

    await provider.generateChatContent(chat, ChatTimeframe.threeMonths, false, false);
    expect(chat.text).toBe("chunk");
    // Only the final update inside `finally` should notify.
    expect(sseService.sendToUser).toHaveBeenCalledTimes(1);
  });

  it("should throttle streamed SSE updates while preserving the final response", async () => {
    provider.streamChunks = ["one", "two", "three"];

    const chat = new ChatHistory(user, "question", "user");
    chat.update = vi.fn().mockResolvedValue(chat);

    await provider.generateChatContent(chat, ChatTimeframe.threeMonths, false, true);

    expect(chat.text).toBe("onetwothree");
    expect(sseService.sendToUser).toHaveBeenCalledTimes(2);
  });

  it("should notify and rethrow when streaming fails", async () => {
    provider.streamError = new Error("Stream fail");

    const chat = new ChatHistory(user, "question", "user");
    chat.update = vi.fn().mockResolvedValue(chat);

    await expect(provider.generateChatContent(chat, ChatTimeframe.threeMonths, false, true)).rejects.toThrow("Stream fail");
    expect(chat.isThinking).toBe(false);
    expect(chat.text).toBe("Stream fail");
    expect(chat.update).toHaveBeenCalled();
  });

  it("should create a new overview when none exists", async () => {
    vi.spyOn(ChatOverview, "findOne").mockResolvedValue(null);
    vi.spyOn(ChatOverview.prototype, "insert").mockImplementation(async function (this: ChatOverview) {
      return this;
    });

    const overview = await provider.generateOverview(ChatOverviewType.accounts);
    expect(overview.type).toBe(ChatOverviewType.accounts);
    expect(overview.model).toBe("test-model");
    expect(promptBuilder.buildDailyOverviewPrompt).toHaveBeenCalledWith(user);
  });

  it("should update an existing overview", async () => {
    const existing = new ChatOverview(user, "Old", ChatOverviewType.holdings);
    existing.update = vi.fn().mockResolvedValue(existing);
    vi.spyOn(ChatOverview, "findOne").mockResolvedValue(existing);

    const overview = await provider.generateOverview(ChatOverviewType.holdings);
    expect(promptBuilder.buildHoldingsOverviewPrompt).toHaveBeenCalledWith(user);
    expect(overview.text).toBe("Hello Acc_0");
    expect(existing.model).toBe("test-model");
    expect(existing.update).toHaveBeenCalled();
  });
});
