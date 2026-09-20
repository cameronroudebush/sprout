import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { AccountHistory } from "@backend/account/model/account.history.model.js";
import { Account } from "@backend/account/model/account.model.js";
import { ChatPromptService } from "@backend/chat/chat.prompt.service.js";
import { ChatTimeframe } from "@backend/chat/model/api/chat.request.dto.js";
import { ChatHistory } from "@backend/chat/model/chat.history.model.js";
import { Configuration } from "@backend/config/core.js";
import { Holding } from "@backend/holding/model/holding.model.js";
import { TestEntities } from "@backend/test/entities.js";
import { Transaction } from "@backend/transaction/model/transaction.model.js";
import { TransactionService } from "@backend/transaction/transaction.service.js";

describe("ChatPromptService", () => {
  let service: ChatPromptService;
  let transactionService: Mocked<TransactionService>;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.clearAllMocks();

    transactionService = {
      findSubscriptions: vi.fn().mockResolvedValue([
        {
          description: "Netflix",
          averageAmount: 15.99,
          period: "monthly",
          account: TestEntities.account,
          transaction: TestEntities.transaction,
        },
      ]),
    } as unknown as Mocked<TransactionService>;

    service = new ChatPromptService(transactionService);

    vi.spyOn(Account, "find").mockResolvedValue([TestEntities.account]);
    vi.spyOn(Account, "convertListToTargetCurrency").mockImplementation((list: any) => list);

    const ah1 = new AccountHistory(TestEntities.account, new Date("2026-06-01"), 1000, 1000);
    const ah2 = new AccountHistory(TestEntities.account, new Date("2026-06-02"), 1050, 1050);
    vi.spyOn(AccountHistory, "find").mockResolvedValue([ah1, ah2]);
    vi.spyOn(AccountHistory, "convertListToTargetCurrency").mockImplementation((list: any) => list);

    vi.spyOn(Transaction, "find").mockResolvedValue([TestEntities.transaction]);
    vi.spyOn(Transaction, "convertListToTargetCurrency").mockImplementation((list: any) => list);
    vi.spyOn(Holding, "find").mockResolvedValue([TestEntities.holding]);
    vi.spyOn(Holding, "convertListToTargetCurrency").mockImplementation((list: any) => list);
    vi.spyOn(ChatHistory, "find").mockResolvedValue([]);
  });

  describe("buildChatPrompt, buildDailyOverviewPrompt, buildHoldingsOverviewPrompt", () => {
    it("should build chat prompt with charts allowed and timeframe filtering", async () => {
      const payload = await service.buildChatPrompt(user, ChatTimeframe.sixMonths, true);
      expect(payload.contents).toBeDefined();
      expect(payload.idMap).toBeDefined();
    });

    it("should build daily overview prompt", async () => {
      const payload = await service.buildDailyOverviewPrompt(user);
      expect(payload.contents).toBeDefined();
    });

    it("should build holdings overview prompt", async () => {
      const payload = await service.buildHoldingsOverviewPrompt(user);
      expect(payload.contents).toBeDefined();
    });
  });

  describe("getTimeframeDate, cleanupUserMax, and formatCleanHistory", () => {
    it("should compute timeframe dates correctly", () => {
      expect((service as unknown as { getTimeframeDate: (t: ChatTimeframe) => Date }).getTimeframeDate(ChatTimeframe.oneDay)).toBeDefined();
      expect((service as unknown as { getTimeframeDate: (t: ChatTimeframe) => Date }).getTimeframeDate(ChatTimeframe.sixMonths)).toBeDefined();
      expect((service as unknown as { getTimeframeDate: (t: ChatTimeframe) => Date }).getTimeframeDate(ChatTimeframe.oneYear)).toBeDefined();
      expect((service as unknown as { getTimeframeDate: (t: ChatTimeframe) => Date }).getTimeframeDate(ChatTimeframe.threeMonths)).toBeDefined();
    });

    it("should cleanup user max chat history", async () => {
      vi.spyOn(ChatHistory, "find").mockResolvedValue([{ id: "h1" } as any, { id: "h2" } as any]);
      vi.spyOn(ChatHistory, "deleteMany").mockResolvedValue({} as any);

      Configuration.server.prompt.maxChatHistory = 1;
      await (service as unknown as { cleanupUserMax: (u: unknown) => Promise<void> }).cleanupUserMax(user);

      expect(ChatHistory.deleteMany).toHaveBeenCalledWith(["h2"]);
    });

    it("should clean and format chat history with consecutive same-role messages", () => {
      const msgUser1 = new ChatHistory(user, "Hello 1", "user");
      const msgUser2 = new ChatHistory(user, "Hello 2", "user");

      const msgModelDefault = new ChatHistory(user, ChatHistory.DEFAULT_MODEL_TEXT, "model");

      const msgModel429 = new ChatHistory(user, "(Code: 429) Rate limit hit", "model");
      vi.spyOn(msgModel429, "deIdentifyText").mockReturnValue("Rate limit hit");

      const msgModel2 = new ChatHistory(user, "Second answer", "model");
      vi.spyOn(msgModel2, "deIdentifyText").mockReturnValue("Second answer");

      const history = [msgUser1, msgUser2, msgModelDefault, msgModel429, msgModel2];
      const formatted = (
        service as unknown as { formatCleanHistory: (h: ChatHistory[], m: Map<string, string>) => Array<{ role: string; parts: Array<{ text: string }> }> }
      ).formatCleanHistory(history, new Map());

      expect(formatted.length).toBe(2);
      expect(formatted[0]?.role).toBe("user");
      expect(formatted[0]?.parts[0]?.text).toBe("Hello 2");
      expect(formatted[1]?.role).toBe("model");
      expect(formatted[1]?.parts[0]?.text).toBe("Second answer");
    });
  });
});
