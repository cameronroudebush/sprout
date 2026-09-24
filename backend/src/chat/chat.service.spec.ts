import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { ChatPromptService } from "@backend/chat/chat.prompt.service.js";
import { ChatService } from "@backend/chat/chat.service.js";
import { GeminiChatProvider } from "@backend/chat/provider/gemini.chat.provider.js";
import { OpenCodeChatProvider } from "@backend/chat/provider/open-code.chat.provider.js";
import { Configuration } from "@backend/config/core.js";
import { SSEService } from "@backend/sse/sse.service.js";
import { TestEntities } from "@backend/test/entities.js";
import { InternalServerErrorException } from "@nestjs/common";
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

describe("ChatService", () => {
  let service: ChatService;
  let sseService: Mocked<SSEService>;
  let promptBuilder: Mocked<ChatPromptService>;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.restoreAllMocks();

    sseService = { sendToUser: vi.fn() } as unknown as Mocked<SSEService>;
    promptBuilder = {} as unknown as Mocked<ChatPromptService>;

    service = new ChatService(sseService, promptBuilder);
    Configuration.server.prompt.type = "gemini";
  });

  afterEach(() => {
    Configuration.server.prompt.type = "gemini";
  });

  it("should build a gemini provider using the configured chat model", async () => {
    const model = await service.getModel(user);
    expect(model).toBeInstanceOf(GeminiChatProvider);
    expect(model.modelName).toBe(Configuration.server.prompt.gemini.chatModel);
  });

  it("should build a gemini provider using the configured overview model", async () => {
    const model = await service.getModel(user, "overview");
    expect(model).toBeInstanceOf(GeminiChatProvider);
    expect(model.modelName).toBe(Configuration.server.prompt.gemini.overviewModel);
  });

  it("should build an OpenCode Zen provider", async () => {
    Configuration.server.prompt.type = "opencode-zen";

    const model = await service.getModel(user, "overview");
    expect(model).toBeInstanceOf(OpenCodeChatProvider);
    expect(model.modelName).toBe(Configuration.server.prompt.openCode.overviewModel);
  });

  it("should build an OpenCode Go provider", async () => {
    Configuration.server.prompt.type = "opencode-go";

    const model = await service.getModel(user);
    expect(model).toBeInstanceOf(OpenCodeChatProvider);
    expect(model.modelName).toBe(Configuration.server.prompt.openCode.chatModel);
  });

  it("should throw for an unsupported provider type", async () => {
    Configuration.server.prompt.type = "other" as any;
    await expect(service.getModel(user)).rejects.toThrow(InternalServerErrorException);
  });
});
