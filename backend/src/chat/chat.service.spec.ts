import { setupTests } from "@backend/test/helpers";
setupTests();

import { ChatService } from "@backend/chat/chat.service";
import { SSEService } from "@backend/sse/sse.service";
import { ChatPromptService } from "@backend/chat/chat.prompt.service";
import { Configuration } from "@backend/config/core";
import { TestEntities } from "@backend/test/entities";
import { BadRequestException } from "@nestjs/common";

describe("ChatService", () => {
  let service: ChatService;
  let sseService: jest.Mocked<SSEService>;
  let promptBuilder: jest.Mocked<ChatPromptService>;
  const user = TestEntities.user;

  beforeEach(() => {
    jest.clearAllMocks();

    sseService = {
      sendToUser: jest.fn(),
    } as any;

    promptBuilder = {
      buildChatPrompt: jest.fn().mockResolvedValue({ contents: "chat prompt", idMap: new Map() }),
      buildDailyOverviewPrompt: jest.fn().mockResolvedValue({ contents: "daily overview prompt", idMap: new Map() }),
      buildHoldingsOverviewPrompt: jest.fn().mockResolvedValue({ contents: "holdings overview prompt", idMap: new Map() }),
    } as any;

    service = new ChatService(sseService, promptBuilder);
  });

  describe("getModel", () => {
    it("should throw BadRequestException if gemini API key is missing", async () => {
      const originalKey = Configuration.server.prompt.gemini.key;
      Configuration.server.prompt.gemini.key = "";

      await expect(service.getModel(user)).rejects.toThrow(BadRequestException);

      Configuration.server.prompt.gemini.key = originalKey;
    });

    it("should return model wrappers when gemini is properly configured", async () => {
      const model = await service.getModel(user, "chat");
      expect(model.type).toBeDefined();
    });
  });
});
