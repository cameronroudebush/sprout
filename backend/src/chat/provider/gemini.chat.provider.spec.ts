import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { ChatPromptService } from "@backend/chat/chat.prompt.service.js";
import { ChatTimeframe } from "@backend/chat/model/api/chat.request.dto.js";
import { ChatHistory } from "@backend/chat/model/chat.history.model.js";
import { ChatOverview } from "@backend/chat/model/chat.overview.model.js";
import { ChatOverviewType } from "@backend/chat/model/chat.overview.type.js";
import { GeminiChatProvider } from "@backend/chat/provider/gemini.chat.provider.js";
import { Configuration } from "@backend/config/core.js";
import { SSEEventType } from "@backend/sse/model/event.model.js";
import { SSEService } from "@backend/sse/sse.service.js";
import { TestEntities } from "@backend/test/entities.js";
import { BadRequestException, InternalServerErrorException } from "@nestjs/common";
import { Mocked } from "vitest";

const mockModels = {
  countTokens: vi.fn(),
  generateContent: vi.fn(),
  generateContentStream: vi.fn(),
};

vi.mock("@google/genai", () => {
  return {
    GoogleGenAI: class MockGoogleGenAI {
      models = mockModels;
    },
  };
});

describe("GeminiChatProvider", () => {
  let provider: GeminiChatProvider;
  let sseService: Mocked<SSEService>;
  let promptBuilder: Mocked<ChatPromptService>;
  const user = TestEntities.user;
  const contents = [{ role: "user", parts: [{ text: "prompt" }] }];

  beforeEach(() => {
    vi.restoreAllMocks();
    mockModels.countTokens.mockReset().mockResolvedValue({ totalTokens: 42 });
    mockModels.generateContent.mockReset().mockResolvedValue({ text: "Generated Acc_0" });
    mockModels.generateContentStream.mockReset();

    sseService = { sendToUser: vi.fn() } as unknown as Mocked<SSEService>;
    promptBuilder = {
      buildChatPrompt: vi.fn().mockResolvedValue({ contents, idMap: new Map([["User Checking", "Acc_0"]]) }),
      buildDailyOverviewPrompt: vi.fn().mockResolvedValue({ contents, idMap: new Map([["User Checking", "Acc_0"]]) }),
      buildHoldingsOverviewPrompt: vi.fn().mockResolvedValue({ contents, idMap: new Map() }),
    } as unknown as Mocked<ChatPromptService>;

    provider = new GeminiChatProvider(sseService, promptBuilder, user, "chat");
  });

  it("should throw when no API key is configured", () => {
    const original = Configuration.server.prompt.gemini.key;
    Configuration.server.prompt.gemini.key = "";
    try {
      expect(() => new GeminiChatProvider(sseService, promptBuilder, user, "chat")).toThrow(BadRequestException);
    } finally {
      Configuration.server.prompt.gemini.key = original;
    }
  });

  it("should resolve chat and overview model names", () => {
    expect(provider.modelName).toBe(Configuration.server.prompt.gemini.chatModel);
    expect((provider as any).logger.context).toBe("service:chat:gemini");
    const overview = new GeminiChatProvider(sseService, promptBuilder, user, "overview");
    expect(overview.modelName).toBe(Configuration.server.prompt.gemini.overviewModel);
  });

  it("should count tokens and fall back to zero on failure or missing totals", async () => {
    await expect(provider.countTokens(contents)).resolves.toBe(42);

    mockModels.countTokens.mockResolvedValueOnce({});
    await expect(provider.countTokens(contents)).resolves.toBe(0);

    mockModels.countTokens.mockRejectedValueOnce(new Error("Token error"));
    await expect(provider.countTokens(contents)).resolves.toBe(0);
  });

  it("should stream chat content through the shared base", async () => {
    mockModels.generateContentStream.mockImplementationOnce(async function* () {
      yield { text: "" };
      yield { text: "Generated " };
      yield { text: "Acc_0" };
    });

    const chat = new ChatHistory(user, "question", "user");
    chat.update = vi.fn().mockResolvedValue(chat);

    await expect(provider.generateChatContent(chat, ChatTimeframe.threeMonths, false, true)).resolves.toBe("Generated User Checking");
    expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.CHAT, chat);
  });

  it("should generate and persist an overview from non-streamed content", async () => {
    vi.spyOn(ChatOverview, "findOne").mockResolvedValue(null);
    vi.spyOn(ChatOverview.prototype, "insert").mockImplementation(async function (this: ChatOverview) {
      return this;
    });

    const overview = await provider.generateOverview(ChatOverviewType.accounts);
    expect(overview.text).toBe("Generated User Checking");
  });

  it("should throw when the model returns no text", async () => {
    mockModels.generateContent.mockResolvedValueOnce({ text: undefined });
    vi.spyOn(ChatOverview, "findOne").mockResolvedValue(null);

    await expect(provider.generateOverview(ChatOverviewType.accounts)).rejects.toThrow(InternalServerErrorException);
  });
});
