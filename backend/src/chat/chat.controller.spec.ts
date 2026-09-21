import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { ChatController } from "@backend/chat/chat.controller.js";
import { ChatService } from "@backend/chat/chat.service.js";
import { ChatTimeframe } from "@backend/chat/model/api/chat.request.dto.js";
import { ChatHistory } from "@backend/chat/model/chat.history.model.js";
import { ChatOverview } from "@backend/chat/model/chat.overview.model.js";
import { ChatOverviewType } from "@backend/chat/model/chat.overview.type.js";
import { SSEEventType } from "@backend/sse/model/event.model.js";
import { SSEService } from "@backend/sse/sse.service.js";
import { TestEntities } from "@backend/test/entities.js";
import { BadRequestException, ConflictException } from "@nestjs/common";
import { Mocked } from "vitest";

describe("ChatController", () => {
  let controller: ChatController;
  let chatService: Mocked<ChatService>;
  let sseService: Mocked<SSEService>;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.restoreAllMocks();

    chatService = {
      getModel: vi.fn(),
    } as any;

    sseService = {
      sendToUser: vi.fn(),
    } as any;

    controller = new ChatController(chatService, sseService);
  });

  describe("new", () => {
    it("should throw ConflictException if user has thinking history item", async () => {
      vi.spyOn(ChatHistory, "count").mockResolvedValue(1);

      await expect(controller.new(user, { message: "Hello", timeframe: ChatTimeframe.threeMonths })).rejects.toThrow(ConflictException);
    });

    it("should throw BadRequestException if message is empty string or whitespace", async () => {
      vi.spyOn(ChatHistory, "count").mockResolvedValue(0);

      await expect(controller.new(user, { message: "   ", timeframe: ChatTimeframe.threeMonths })).rejects.toThrow(BadRequestException);
    });

    it("should create user message and model placeholder, then call model.generateChatContent", async () => {
      vi.spyOn(ChatHistory, "count").mockResolvedValue(0);

      const userChat = ChatHistory.fromPlain({ id: "user-msg", text: "Hello", user });
      userChat.insert = vi.fn().mockResolvedValue(userChat);

      const modelChat = ChatHistory.fromPlain({ id: "model-msg", text: "...", isThinking: true, user });
      modelChat.insert = vi.fn().mockResolvedValue(modelChat);
      modelChat.update = vi.fn().mockResolvedValue(modelChat);

      vi.spyOn(ChatHistory.prototype, "insert").mockResolvedValueOnce(userChat).mockResolvedValueOnce(modelChat);

      const mockModel = {
        generateChatContent: vi.fn().mockResolvedValue("AI Response"),
      };
      chatService.getModel.mockResolvedValue(mockModel as any);

      const res = await controller.new(user, { message: "Hello", timeframe: ChatTimeframe.threeMonths, allowCharts: true });

      expect(mockModel.generateChatContent).toHaveBeenCalledWith(modelChat, ChatTimeframe.threeMonths, true);
      expect(res).toBe("AI Response");
    });

    it("should handle error without message property in catch block", async () => {
      vi.spyOn(ChatHistory, "count").mockResolvedValue(0);

      const userChat = ChatHistory.fromPlain({ id: "user-msg", text: "Hello", user });
      userChat.insert = vi.fn().mockResolvedValue(userChat);

      const modelChat = ChatHistory.fromPlain({ id: "model-msg", text: "...", isThinking: true, user });
      modelChat.insert = vi.fn().mockResolvedValue(modelChat);
      modelChat.update = vi.fn().mockResolvedValue(modelChat);

      vi.spyOn(ChatHistory.prototype, "insert").mockResolvedValueOnce(userChat).mockResolvedValueOnce(modelChat);

      const mockModel = {
        generateChatContent: vi.fn().mockRejectedValue("string error without message property"),
      };
      chatService.getModel.mockResolvedValue(mockModel as any);

      await expect(controller.new(user, { message: "Hello", timeframe: ChatTimeframe.threeMonths })).rejects.toBeDefined();
      expect(modelChat.isThinking).toBe(false);
      expect(modelChat.text).toBe("An unexpected timeout or error occurred.");
      expect(modelChat.update).toHaveBeenCalled();
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.CHAT, modelChat);
    });

    it("should skip cleanup if chat.isThinking is already false when error is caught", async () => {
      vi.spyOn(ChatHistory, "count").mockResolvedValue(0);

      const userChat = ChatHistory.fromPlain({ id: "user-msg", text: "Hello", user });
      userChat.insert = vi.fn().mockResolvedValue(userChat);

      const modelChat = ChatHistory.fromPlain({ id: "model-msg", text: "...", isThinking: true, user });
      modelChat.insert = vi.fn().mockResolvedValue(modelChat);
      modelChat.update = vi.fn().mockResolvedValue(modelChat);

      vi.spyOn(ChatHistory.prototype, "insert").mockResolvedValueOnce(userChat).mockResolvedValueOnce(modelChat);

      const mockModel = {
        generateChatContent: vi.fn().mockImplementation(async () => {
          modelChat.isThinking = false;
          throw new Error("Pre-cleaned error");
        }),
      };
      chatService.getModel.mockResolvedValue(mockModel as any);

      await expect(controller.new(user, { message: "Hello", timeframe: ChatTimeframe.threeMonths })).rejects.toThrow("Pre-cleaned error");
    });

    it("should handle error in generateChatContent and update chat.isThinking when error caught", async () => {
      vi.spyOn(ChatHistory, "count").mockResolvedValue(0);

      const userChat = ChatHistory.fromPlain({ id: "user-msg", text: "Hello", user });
      userChat.insert = vi.fn().mockResolvedValue(userChat);

      const modelChat = ChatHistory.fromPlain({ id: "model-msg", text: "...", isThinking: true, user });
      modelChat.insert = vi.fn().mockResolvedValue(modelChat);
      modelChat.update = vi.fn().mockResolvedValue(modelChat);

      vi.spyOn(ChatHistory.prototype, "insert").mockResolvedValueOnce(userChat).mockResolvedValueOnce(modelChat);

      const mockModel = {
        generateChatContent: vi.fn().mockRejectedValue(new Error("Generation failed")),
      };
      chatService.getModel.mockResolvedValue(mockModel as any);

      await expect(controller.new(user, { message: "Hello", timeframe: ChatTimeframe.threeMonths })).rejects.toThrow("Generation failed");
      expect(modelChat.isThinking).toBe(false);
      expect(modelChat.text).toBe("Generation failed");
      expect(modelChat.update).toHaveBeenCalled();
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.CHAT, modelChat);
    });
  });

  describe("history", () => {
    it("should return ordered chat history", async () => {
      const mockHistory = [ChatHistory.fromPlain({ text: "Hello" })];
      vi.spyOn(ChatHistory, "find").mockResolvedValue(mockHistory);

      const res = await controller.history(user);

      expect(ChatHistory.find).toHaveBeenCalledWith({
        where: { user: { id: user.id } },
        order: { time: "DESC" },
      });
      expect(res).toBe(mockHistory);
    });
  });

  describe("getOverview", () => {
    it("should return fresh existing overview if generated after last sync time", async () => {
      const freshOverview = ChatOverview.fromPlain({
        user,
        type: ChatOverviewType.accounts,
        time: new Date(), // fresh
      });
      vi.spyOn(ChatOverview, "findOne").mockResolvedValue(freshOverview);

      const res = await controller.getOverview(user, ChatOverviewType.accounts);

      expect(res).toBe(freshOverview);
    });

    it("should regenerate overview if missing or stale", async () => {
      const staleOverview = ChatOverview.fromPlain({
        user,
        type: ChatOverviewType.accounts,
        time: new Date(2000, 0, 1),
      });
      vi.spyOn(ChatOverview, "findOne").mockResolvedValue(staleOverview);

      const newOverview = ChatOverview.fromPlain({ user, type: ChatOverviewType.accounts });
      const mockModel = {
        generateOverview: vi.fn().mockResolvedValue(newOverview),
      };
      chatService.getModel.mockResolvedValue(mockModel as any);

      const res = await controller.getOverview(user, ChatOverviewType.accounts);

      expect(mockModel.generateOverview).toHaveBeenCalledWith(ChatOverviewType.accounts);
      expect(res).toBe(newOverview);
    });
  });
});
