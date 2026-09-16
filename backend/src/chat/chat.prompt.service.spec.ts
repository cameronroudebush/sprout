import { setupTests } from "@backend/test/helpers";
setupTests();

import { ChatPromptService } from "@backend/chat/chat.prompt.service";
import { TransactionService } from "@backend/transaction/transaction.service";
import { ChatTimeframe } from "@backend/chat/model/api/chat.request.dto";
import { ChatHistory } from "@backend/chat/model/chat.history.model";
import { Account } from "@backend/account/model/account.model";
import { Holding } from "@backend/holding/model/holding.model";
import { AccountHistory } from "@backend/account/model/account.history.model";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { Configuration } from "@backend/config/core";
import { TestEntities } from "@backend/test/entities";

describe("ChatPromptService", () => {
  let service: ChatPromptService;
  let transactionService: jest.Mocked<TransactionService>;
  const user = TestEntities.user;

  beforeEach(() => {
    jest.clearAllMocks();

    transactionService = {
      findSubscriptions: jest.fn().mockResolvedValue([]),
    } as any;

    service = new ChatPromptService(transactionService);
  });

  describe("buildChatPrompt", () => {
    it("should assemble instructions, contextual data, and clean history", async () => {
      jest.spyOn(Account, "find").mockResolvedValue([TestEntities.account]);
      jest.spyOn(Holding, "find").mockResolvedValue([]);
      jest.spyOn(AccountHistory, "find").mockResolvedValue([]);
      jest.spyOn(Transaction, "find").mockResolvedValue([]);
      jest.spyOn(ChatHistory, "find").mockResolvedValue([]);

      const result = await service.buildChatPrompt(user, ChatTimeframe.threeMonths, true);

      expect(result.idMap).toBeDefined();
      expect(result.contents.length).toBeGreaterThan(0);
    });
  });

  describe("buildDailyOverviewPrompt", () => {
    it("should build prompt payload for daily overview", async () => {
      jest.spyOn(Account, "find").mockResolvedValue([TestEntities.account]);
      jest.spyOn(Holding, "find").mockResolvedValue([]);
      jest.spyOn(AccountHistory, "find").mockResolvedValue([]);
      jest.spyOn(Transaction, "find").mockResolvedValue([]);

      const result = await service.buildDailyOverviewPrompt(user);

      expect(result.contents.length).toBe(1);
    });
  });

  describe("buildHoldingsOverviewPrompt", () => {
    it("should build prompt payload for holdings overview", async () => {
      jest.spyOn(Account, "find").mockResolvedValue([TestEntities.account]);
      jest.spyOn(Holding, "find").mockResolvedValue([]);
      jest.spyOn(AccountHistory, "find").mockResolvedValue([]);
      jest.spyOn(Transaction, "find").mockResolvedValue([]);

      const result = await service.buildHoldingsOverviewPrompt(user);

      expect(result.contents.length).toBe(1);
    });
  });

  describe("cleanupUserMax", () => {
    it("should delete old chat messages exceeding threshold", async () => {
      const history = [ChatHistory.fromPlain({ id: "ch1" }), ChatHistory.fromPlain({ id: "ch2" }), ChatHistory.fromPlain({ id: "ch3" })];

      jest.spyOn(ChatHistory, "find").mockResolvedValue(history as any);
      const deleteManySpy = jest.spyOn(ChatHistory, "deleteMany").mockResolvedValue({} as any);

      const originalMax = Configuration.server.prompt.maxChatHistory;
      Configuration.server.prompt.maxChatHistory = 1;

      await (service as any).cleanupUserMax(user);

      expect(deleteManySpy).toHaveBeenCalledWith(["ch2", "ch3"]);

      Configuration.server.prompt.maxChatHistory = originalMax;
    });
  });
});
