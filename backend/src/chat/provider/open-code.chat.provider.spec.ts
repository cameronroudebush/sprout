import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { ChatPromptService } from "@backend/chat/chat.prompt.service.js";
import { ChatTimeframe } from "@backend/chat/model/api/chat.request.dto.js";
import { ChatHistory } from "@backend/chat/model/chat.history.model.js";
import { ChatOverview } from "@backend/chat/model/chat.overview.model.js";
import { ChatOverviewType } from "@backend/chat/model/chat.overview.type.js";
import { OpenCodeChatProvider } from "@backend/chat/provider/open-code.chat.provider.js";
import { Configuration } from "@backend/config/core.js";
import { SSEEventType } from "@backend/sse/model/event.model.js";
import { SSEService } from "@backend/sse/sse.service.js";
import { TestEntities } from "@backend/test/entities.js";
import { BadRequestException, InternalServerErrorException } from "@nestjs/common";
import { ThrottlerException } from "@nestjs/throttler";
import { Mocked } from "vitest";

/** Builds a fetch Response that resolves to the given JSON payload. */
function jsonResponse(body: unknown, ok = true, status = 200): Response {
  return {
    ok,
    status,
    json: async () => body,
    text: async () => (typeof body === "string" ? body : JSON.stringify(body)),
  } as unknown as Response;
}

/** Builds a fetch Response whose body is an SSE stream of the given raw chunks. */
function sseResponse(chunks: string[]): Response {
  const encoder = new TextEncoder();
  const stream = new ReadableStream<Uint8Array>({
    start(controller) {
      for (const chunk of chunks) controller.enqueue(encoder.encode(chunk));
      controller.close();
    },
  });
  return { ok: true, status: 200, body: stream } as unknown as Response;
}

const promptContents = [
  { role: "user", parts: [{ text: "hello" }] },
  { role: "model", parts: [{ text: "prior" }] },
  { role: "user", parts: [{ text: "again" }] },
];

describe("OpenCodeChatProvider", () => {
  let provider: OpenCodeChatProvider;
  let sseService: Mocked<SSEService>;
  let promptBuilder: Mocked<ChatPromptService>;
  let fetchMock: ReturnType<typeof vi.fn>;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.restoreAllMocks();

    fetchMock = vi.fn();
    vi.stubGlobal("fetch", fetchMock);

    sseService = { sendToUser: vi.fn() } as unknown as Mocked<SSEService>;
    promptBuilder = {
      buildChatPrompt: vi.fn().mockResolvedValue({ contents: promptContents, idMap: new Map() }),
      buildDailyOverviewPrompt: vi.fn().mockResolvedValue({ contents: promptContents, idMap: new Map() }),
      buildHoldingsOverviewPrompt: vi.fn().mockResolvedValue({ contents: promptContents, idMap: new Map() }),
    } as unknown as Mocked<ChatPromptService>;

    Configuration.server.prompt.openCode.key = "test-opencode-key";
    provider = new OpenCodeChatProvider(sseService, promptBuilder, user, "chat", "opencode-zen");
  });

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it("should throw when no API key is configured", () => {
    Configuration.server.prompt.openCode.key = "";
    try {
      expect(() => new OpenCodeChatProvider(sseService, promptBuilder, user, "chat", "opencode-zen")).toThrow(BadRequestException);
    } finally {
      Configuration.server.prompt.openCode.key = "test-opencode-key";
    }
  });

  it("should resolve chat and overview model names", () => {
    expect(provider.modelName).toBe("opencode-chat-model");
    expect((provider as any).logger.context).toBe("service:chat:opencode-zen");
    const overview = new OpenCodeChatProvider(sseService, promptBuilder, user, "overview", "opencode-zen");
    expect(overview.modelName).toBe("opencode-overview-model");
  });

  it("should estimate tokens from the prompt payload", async () => {
    await expect(provider.countTokens(promptContents)).resolves.toBeGreaterThan(0);
  });

  it("should send an OpenAI compatible request to the Zen gateway and return assistant content", async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse({ choices: [{ message: { content: "answer" } }] }));
    vi.spyOn(ChatOverview, "findOne").mockResolvedValue(null);
    vi.spyOn(ChatOverview.prototype, "insert").mockImplementation(async function (this: ChatOverview) {
      return this;
    });

    const overview = await provider.generateOverview(ChatOverviewType.accounts);
    expect(overview.text).toBe("answer");

    const [url, init] = fetchMock.mock.calls[0]!;
    expect(url).toBe("https://opencode.ai/zen/v1/chat/completions");
    expect((init as RequestInit).headers).toMatchObject({ Authorization: "Bearer test-opencode-key", "User-Agent": "sprout/1.0" });
    expect(JSON.parse((init as RequestInit).body as string)).toEqual({
      model: "opencode-chat-model",
      messages: [
        { role: "user", content: "hello" },
        { role: "assistant", content: "prior" },
        { role: "user", content: "again" },
      ],
      stream: false,
    });
  });

  it("should route the Go gateway to its own base URL", async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse({ choices: [{ message: { content: "answer" } }] }));
    vi.spyOn(ChatOverview, "findOne").mockResolvedValue(null);
    vi.spyOn(ChatOverview.prototype, "insert").mockImplementation(async function (this: ChatOverview) {
      return this;
    });

    const goProvider = new OpenCodeChatProvider(sseService, promptBuilder, user, "chat", "opencode-go");
    expect((goProvider as any).logger.context).toBe("service:chat:opencode-go");
    await goProvider.generateOverview(ChatOverviewType.accounts);

    expect(fetchMock.mock.calls[0]![0]).toBe("https://opencode.ai/zen/go/v1/chat/completions");
  });

  it("should send a stable hashed session id so the gateway can route and cache efficiently", async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse({ choices: [{ message: { content: "answer" } }] }));
    vi.spyOn(ChatOverview, "findOne").mockResolvedValue(null);
    vi.spyOn(ChatOverview.prototype, "insert").mockImplementation(async function (this: ChatOverview) {
      return this;
    });

    await provider.generateOverview(ChatOverviewType.accounts);

    const session = (fetchMock.mock.calls[0]![1] as RequestInit).headers as Record<string, string>;
    expect(session["x-opencode-session"]).toMatch(/^[a-f0-9]{64}$/);

    // The same conversation (user + model type) always resolves to the same session.
    expect(session["x-opencode-session"]).toBe((provider as any).sessionId);

    // Chat and overview are distinct conversations, so they must not share a session.
    const overview = new OpenCodeChatProvider(sseService, promptBuilder, user, "overview", "opencode-zen");
    expect((overview as any).sessionId).not.toBe(session["x-opencode-session"]);
  });

  it("should throw when a non-streamed response has no content", async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse({ choices: [{ message: {} }] }));
    vi.spyOn(ChatOverview, "findOne").mockResolvedValue(null);

    await expect(provider.generateOverview(ChatOverviewType.accounts)).rejects.toThrow(InternalServerErrorException);
  });

  it("should surface JSON error messages from failed requests", async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse({ error: { message: "bad gateway" } }, false, 502));
    vi.spyOn(ChatOverview, "findOne").mockResolvedValue(null);

    await expect(provider.generateOverview(ChatOverviewType.accounts)).rejects.toThrow("bad gateway");
  });

  it("should keep the raw body when a failed request is not JSON", async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse("plain failure", false, 500));
    vi.spyOn(ChatOverview, "findOne").mockResolvedValue(null);

    await expect(provider.generateOverview(ChatOverviewType.accounts)).rejects.toThrow("plain failure");
  });

  it("should keep the raw body when JSON has no error message", async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse({ foo: "bar" }, false, 500));
    vi.spyOn(ChatOverview, "findOne").mockResolvedValue(null);

    await expect(provider.generateOverview(ChatOverviewType.accounts)).rejects.toThrow('{"foo":"bar"}');
  });

  it("should fall back to a status message for empty failed responses", async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse("", false, 500));
    vi.spyOn(ChatOverview, "findOne").mockResolvedValue(null);

    await expect(provider.generateOverview(ChatOverviewType.accounts)).rejects.toThrow("OpenCode request failed with status 500");
  });

  it("should map a 429 response to a throttling exception", async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse({ error: { message: "rate limited" } }, false, 429));
    vi.spyOn(ChatOverview, "findOne").mockResolvedValue(null);

    await expect(provider.generateOverview(ChatOverviewType.accounts)).rejects.toThrow(ThrottlerException);
  });

  it("should stream chat content and stop at the [DONE] sentinel", async () => {
    fetchMock.mockResolvedValueOnce(
      sseResponse([
        'data: {"choices":[{"delta":{"content":"Hel"}}]}\n\n',
        'data: {"choices":[{"delta":{"content":"lo"}}]}\n\n',
        ": keep-alive comment\n\n",
        "data: not-json\n\n",
        'data: {"choices":[{"delta":{}}]}\n\n',
        "data: [DONE]\n\n",
        'data: {"choices":[{"delta":{"content":"ignored"}}]}\n\n',
      ]),
    );

    const chat = new ChatHistory(user, "question", "user");
    chat.update = vi.fn().mockResolvedValue(chat);

    await expect(provider.generateChatContent(chat, ChatTimeframe.threeMonths, false, true)).resolves.toBe("Hello");
    expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.CHAT, chat);

    const [, init] = fetchMock.mock.calls[0]!;
    expect(JSON.parse((init as RequestInit).body as string).stream).toBe(true);
  });

  it("should safely handle a streamed response without a body", async () => {
    fetchMock.mockResolvedValueOnce({ ok: true, status: 200, body: null } as unknown as Response);

    const chat = new ChatHistory(user, "question", "user");
    chat.update = vi.fn().mockResolvedValue(chat);

    await expect(provider.generateChatContent(chat, ChatTimeframe.threeMonths, false, true)).resolves.toBe("question");
  });

  it("should finish streaming cleanly when no [DONE] sentinel is sent", async () => {
    fetchMock.mockResolvedValueOnce(sseResponse(['data: {"choices":[{"delta":{"content":"complete"}}]}\n\n']));

    const chat = new ChatHistory(user, "question", "user");
    chat.update = vi.fn().mockResolvedValue(chat);

    await expect(provider.generateChatContent(chat, ChatTimeframe.threeMonths, false, false)).resolves.toBe("complete");
  });
});
