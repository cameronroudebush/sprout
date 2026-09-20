import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { ChatPromptService } from "@backend/chat/chat.prompt.service.js";
import { ChatTimeframe } from "@backend/chat/model/api/chat.request.dto.js";
import { ChatHistory } from "@backend/chat/model/chat.history.model.js";
import { ChatOverview } from "@backend/chat/model/chat.overview.model.js";
import { ChatOverviewType } from "@backend/chat/model/chat.overview.type.js";
import { ChatService } from "@backend/chat/chat.service.js";
import { Configuration } from "@backend/config/core.js";
import { SSEEventType } from "@backend/sse/model/event.model.js";
import { SSEService } from "@backend/sse/sse.service.js";
import { TestEntities } from "@backend/test/entities.js";
import { BadRequestException, InternalServerErrorException } from "@nestjs/common";
import { ThrottlerException } from "@nestjs/throttler";

const mockModels = {
  countTokens: vi.fn().mockResolvedValue({ totalTokens: 42 }),
  generateContent: vi.fn().mockResolvedValue({ text: "Generated AI Overview Acc_0" }),
  generateContentStream: vi.fn().mockImplementation(async function* () {
    yield { text: "Generated " };
    yield { text: "AI Response Acc_0" };
  }),
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

    sseService = {
      sendToUser: vi.fn(),
    } as unknown as Mocked<SSEService>;

    promptBuilder = {
      buildChatPrompt: vi.fn().mockResolvedValue({ contents: "chat prompt", idMap: new Map([["Acc_0", "User Checking"]]) }),
      buildDailyOverviewPrompt: vi.fn().mockResolvedValue({ contents: "daily overview prompt", idMap: new Map() }),
      buildHoldingsOverviewPrompt: vi.fn().mockResolvedValue({ contents: "holdings overview prompt", idMap: new Map() }),
    } as unknown as Mocked<ChatPromptService>;

    service = new ChatService(sseService, promptBuilder);
  });

  describe("getModel & injectChartColors", () => {
    it("should throw BadRequestException if gemini API key is missing", async () => {
      const originalKey = Configuration.server.prompt.gemini.key;
      Configuration.server.prompt.gemini.key = "";

      await expect(service.getModel(user)).rejects.toThrow(BadRequestException);

      Configuration.server.prompt.gemini.key = originalKey;
    });

    it("should throw InternalServerErrorException if prompt type is not gemini", async () => {
      const origType = Configuration.server.prompt.type;
      Configuration.server.prompt.type = "other" as any;

      await expect(service.getModel(user)).rejects.toThrow(InternalServerErrorException);

      Configuration.server.prompt.type = origType;
    });

    it("should inject colors into line and pie chart markdown strings", () => {
      const lineChartText = '```chart\n{"type":"line","series":[{"label":"Checking"}]}\n```';
      const lineResult = (service as unknown as { injectChartColors: (t: string) => string }).injectChartColors(lineChartText);
      expect(lineResult).toContain("color");

      const pieChartText = '```chart\n{"type":"pie","data":{"Dining":100}}\n```';
      const pieResult = (service as unknown as { injectChartColors: (t: string) => string }).injectChartColors(pieChartText);
      expect(pieResult).toContain("colors");

      const invalidJsonText = "```chart\n{invalid}\n```";
      expect((service as unknown as { injectChartColors: (t: string) => string }).injectChartColors(invalidJsonText)).toBe(invalidJsonText);
    });

    it("should test model wrapper methods countTokens, generateChatContent, generateOverview", async () => {
      const modelWrapper = await service.getModel(user, "chat");

      const tokens = await modelWrapper.countTokens("test input");
      expect(tokens).toBe(42);

      const chatMsg = new ChatHistory(user, "User question", "user");
      chatMsg.update = vi.fn().mockResolvedValue(chatMsg);

      await modelWrapper.generateChatContent(chatMsg, ChatTimeframe.threeMonths, false, true);
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.CHAT, chatMsg);

      vi.spyOn(ChatOverview, "findOne").mockResolvedValue(null);
      vi.spyOn(ChatOverview.prototype, "insert").mockImplementation(async function (this: ChatOverview) {
        return this;
      });

      const overview = await modelWrapper.generateOverview(ChatOverviewType.daily);
      expect(overview).toBeDefined();

      const existingOverview = new ChatOverview(user, "Old text", ChatOverviewType.holdings);
      existingOverview.update = vi.fn().mockResolvedValue(existingOverview);
      vi.spyOn(ChatOverview, "findOne").mockResolvedValue(existingOverview);

      const holdingsOverview = await modelWrapper.generateOverview(ChatOverviewType.holdings);
      expect(holdingsOverview).toBeDefined();
    });

    it("should handle 503 retry overload, JSON parse errors, and error branches in generateOverview", async () => {
      vi.useFakeTimers();
      const modelWrapper = await service.getModel(user, "overview");

      vi.spyOn(ChatOverview, "findOne").mockResolvedValue(null);
      vi.spyOn(ChatOverview.prototype, "insert").mockImplementation(async function (this: ChatOverview) {
        return this;
      });

      // 503 overloaded retry then success
      mockModels.generateContent.mockRejectedValueOnce({ code: 503, message: "high demand" }).mockResolvedValueOnce({ text: "Recovered summary" });

      const promise = modelWrapper.generateOverview(ChatOverviewType.daily);
      await vi.advanceTimersByTimeAsync(10000);
      const res = await promise;
      expect(res).toBeDefined();

      // Retry limit reached throws the error
      mockModels.generateContent.mockRejectedValue({ code: 503, message: "high demand" });
      const promiseFail = modelWrapper.generateOverview(ChatOverviewType.daily);
      const expectPromise = expect(promiseFail).rejects.toBeDefined();
      await vi.advanceTimersByTimeAsync(30000);
      await expectPromise;

      vi.useRealTimers();

      // 429 error
      mockModels.generateContent.mockRejectedValueOnce(new Error("429 Too Many Requests"));
      await expect(modelWrapper.generateOverview(ChatOverviewType.daily)).rejects.toThrow(ThrottlerException);

      // JSON parse error handling inside catch block (message starts with { but is invalid JSON)
      mockModels.generateContent.mockRejectedValueOnce(new Error("{ invalid json string"));
      await expect(modelWrapper.generateOverview(ChatOverviewType.daily)).rejects.toThrow("{ invalid json string");

      // JSON error message
      mockModels.generateContent.mockRejectedValueOnce(new Error('{"error":{"message":"API Error Msg"}}'));
      await expect(modelWrapper.generateOverview(ChatOverviewType.daily)).rejects.toThrow("API Error Msg");

      // Object error with error.message
      mockModels.generateContent.mockRejectedValueOnce({ error: { message: "Direct error" } });
      await expect(modelWrapper.generateOverview(ChatOverviewType.daily)).rejects.toThrow("Direct error");
    });

    it("should handle error in generateChatContent and countTokens failure", async () => {
      mockModels.countTokens.mockRejectedValueOnce(new Error("Token error"));

      const modelWrapper = await service.getModel(user, "chat");
      const tokens = await modelWrapper.countTokens("test input");
      expect(tokens).toBe(0);

      mockModels.generateContentStream.mockRejectedValueOnce(new Error("Stream fail"));

      const chatMsg = new ChatHistory(user, "User question", "user");
      chatMsg.update = vi.fn().mockResolvedValue(chatMsg);

      await expect(modelWrapper.generateChatContent(chatMsg, ChatTimeframe.threeMonths, false, false)).rejects.toThrow("Stream fail");
    });
  });
});
