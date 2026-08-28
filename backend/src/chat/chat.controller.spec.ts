import { setupTests } from "@backend/test/helpers";
setupTests();

import { ChatController } from "@backend/chat/chat.controller";
import { ChatService } from "@backend/chat/chat.service";
import { SSEService } from "@backend/sse/sse.service";
import { ChatHistory } from "@backend/chat/model/chat.history.model";
import { ChatOverview } from "@backend/chat/model/chat.overview.model";
import { ChatOverviewType } from "@backend/chat/model/chat.overview.type";
import { TestEntities } from "@backend/test/entities";
import { BadRequestException, ConflictException } from "@nestjs/common";
import { ChatTimeframe } from "@backend/chat/model/api/chat.request.dto";

describe("ChatController", () => {
  let controller: ChatController;
  let chatService: jest.Mocked<ChatService>;
  let sseService: jest.Mocked<SSEService>;
  const user = TestEntities.user;

  beforeEach(() => {
    jest.clearAllMocks();

    chatService = {
      getModel: jest.fn(),
    } as any;

    sseService = {
      sendToUser: jest.fn(),
    } as any;

    controller = new ChatController(chatService, sseService);
  });

  describe("new", () => {
    it("should throw ConflictException if user has thinking history item", async () => {
      jest.spyOn(ChatHistory, "count").mockResolvedValue(1);

      await expect(controller.new(user, { message: "Hello", timeframe: ChatTimeframe.threeMonths })).rejects.toThrow(ConflictException);
    });

    it("should throw BadRequestException if message is empty string or whitespace", async () => {
      jest.spyOn(ChatHistory, "count").mockResolvedValue(0);

      await expect(controller.new(user, { message: "   ", timeframe: ChatTimeframe.threeMonths })).rejects.toThrow(BadRequestException);
    });

    it("should create user message and model placeholder, then call model.generateChatContent", async () => {
      jest.spyOn(ChatHistory, "count").mockResolvedValue(0);

      const userChat = ChatHistory.fromPlain({ id: "user-msg", text: "Hello", user });
      userChat.insert = jest.fn().mockResolvedValue(userChat);

      const modelChat = ChatHistory.fromPlain({ id: "model-msg", text: "...", isThinking: true, user });
      modelChat.insert = jest.fn().mockResolvedValue(modelChat);
      modelChat.update = jest.fn().mockResolvedValue(modelChat);

      jest.spyOn(ChatHistory.prototype, "insert").mockResolvedValueOnce(userChat).mockResolvedValueOnce(modelChat);

      const mockModel = {
        generateChatContent: jest.fn().mockResolvedValue("AI Response"),
      };
      chatService.getModel.mockResolvedValue(mockModel as any);

      const res = await controller.new(user, { message: "Hello", timeframe: ChatTimeframe.threeMonths, allowCharts: true });

      expect(mockModel.generateChatContent).toHaveBeenCalledWith(modelChat, ChatTimeframe.threeMonths, true);
      expect(res).toBe("AI Response");
    });
  });

  describe("history", () => {
    it("should return ordered chat history", async () => {
      const mockHistory = [ChatHistory.fromPlain({ text: "Hello" })];
      jest.spyOn(ChatHistory, "find").mockResolvedValue(mockHistory);

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
      jest.spyOn(ChatOverview, "findOne").mockResolvedValue(freshOverview);

      const res = await controller.getOverview(user, ChatOverviewType.accounts);

      expect(res).toBe(freshOverview);
    });

    it("should regenerate overview if missing or stale", async () => {
      jest.spyOn(ChatOverview, "findOne").mockResolvedValue(null);

      const newOverview = ChatOverview.fromPlain({ user, type: ChatOverviewType.accounts });
      const mockModel = {
        generateOverview: jest.fn().mockResolvedValue(newOverview),
      };
      chatService.getModel.mockResolvedValue(mockModel as any);

      const res = await controller.getOverview(user, ChatOverviewType.accounts);

      expect(mockModel.generateOverview).toHaveBeenCalledWith(ChatOverviewType.accounts);
      expect(res).toBe(newOverview);
    });
  });
});
