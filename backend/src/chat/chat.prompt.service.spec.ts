import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { AccountHistory } from "@backend/account/model/account.history.model.js";
import { Account } from "@backend/account/model/account.model.js";
import { BudgetService } from "@backend/budget/budget.service.js";
import { Category } from "@backend/category/model/category.model.js";
import { ChatPromptService } from "@backend/chat/chat.prompt.service.js";
import { ChatTimeframe } from "@backend/chat/model/api/chat.request.dto.js";
import { ChatHistory } from "@backend/chat/model/chat.history.model.js";
import { Configuration } from "@backend/config/core.js";
import { MarketQuoteType, MarketState } from "@backend/holding/model/api/mark.index.dto.js";
import { HoldingHistory } from "@backend/holding/model/holding.history.model.js";
import { Holding } from "@backend/holding/model/holding.model.js";
import { HoldingService } from "@backend/holding/holding.service.js";
import { TestEntities } from "@backend/test/entities.js";
import { Transaction } from "@backend/transaction/model/transaction.model.js";
import { TransactionService } from "@backend/transaction/transaction.service.js";
import { User } from "@backend/user/model/user.model.js";
import { Mocked } from "vitest";

describe("ChatPromptService", () => {
  let service: ChatPromptService;
  let transactionService: Mocked<TransactionService>;
  let budgetService: Mocked<BudgetService>;
  let holdingService: Mocked<HoldingService>;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.clearAllMocks();
    user.config.enableBudgeting = true;

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

    budgetService = {
      getBudgetOverview: vi.fn().mockResolvedValue({
        year: 2026,
        month: 6,
        totalBudgeted: 500,
        totalSpent: 175,
        totalRemaining: 325,
        totalOverBudgetAmount: 50,
        items: [
          {
            category: { name: "Groceries" },
            budgetId: "budget-1",
            budgetedAmount: 300,
            actualSpent: 125,
            remaining: 175,
            isOverBudget: false,
          },
          {
            category: { name: "Dining" },
            budgetId: undefined,
            budgetedAmount: 0,
            actualSpent: 50,
            remaining: -50,
            isOverBudget: true,
          },
        ],
      }),
    } as unknown as Mocked<BudgetService>;

    holdingService = {
      getLiveHoldingPrices: vi.fn().mockResolvedValue([]),
    } as unknown as Mocked<HoldingService>;

    service = new ChatPromptService(transactionService, budgetService, holdingService);

    vi.spyOn(Account, "find").mockResolvedValue([TestEntities.account]);
    vi.spyOn(Account, "convertListToTargetCurrency").mockImplementation((list: any) => list);

    const ah1 = new AccountHistory(TestEntities.account, new Date("2026-06-01"), 1000, 1000);
    const ah2 = new AccountHistory(TestEntities.account, new Date("2026-06-02"), 1050, 1050);
    vi.spyOn(AccountHistory, "find").mockResolvedValue([ah1, ah2]);
    vi.spyOn(AccountHistory, "convertListToTargetCurrency").mockImplementation((list: any) => list);

    vi.spyOn(Transaction, "find").mockResolvedValue([TestEntities.transaction]);
    vi.spyOn(Transaction, "convertListToTargetCurrency").mockImplementation((list: any) => list);
    vi.spyOn(Category, "find").mockResolvedValue([]);
    vi.spyOn(Holding, "find").mockResolvedValue([TestEntities.holding]);
    vi.spyOn(Holding, "convertListToTargetCurrency").mockImplementation((list: any) => list);

    vi.spyOn(HoldingHistory, "find").mockResolvedValue([]);
    vi.spyOn(HoldingHistory, "convertListToTargetCurrency").mockImplementation((list: any) => list);

    vi.spyOn(ChatHistory, "find").mockResolvedValue([]);
  });

  describe("buildChatPrompt, buildDailyOverviewPrompt, buildHoldingsOverviewPrompt", () => {
    it("should build chat prompt with charts allowed and timeframe filtering", async () => {
      const payload = await service.buildChatPrompt(user, ChatTimeframe.sixMonths, true);
      const promptText = payload.contents[0]!.parts[0]!.text;
      const contextData = JSON.parse(promptText.split("CONTEXTUAL DATA:")[1]!);
      expect(payload.contents).toBeDefined();
      expect(payload.idMap).toBeDefined();
      expect(promptText).toContain("NEVER use Markdown tables");
      expect(contextData.budget).toEqual({
        month: "June 2026",
        totalBudgeted: 500,
        totalSpent: 175,
        totalRemaining: 325,
        totalOverBudgetAmount: 50,
        categories: [
          { category: "Cat_0", hasLimit: true, limit: 300, spent: 125, remaining: 175, overLimit: false },
          { category: "Cat_1", hasLimit: false, limit: 0, spent: 50, remaining: -50, overLimit: false },
        ],
      });
      expect(contextData.transactions[0].split("|")[3]).toBe("Cat_0");
      expect(JSON.stringify(contextData)).not.toContain("Groceries");
      expect(JSON.stringify(contextData)).not.toContain("Dining");
      expect(JSON.stringify(contextData)).not.toContain("budget-1");
      expect(JSON.stringify(contextData)).not.toContain("category-default-id");
      expect(payload.idMap.get("Groceries")).toBe("Cat_0");
      expect(budgetService.getBudgetOverview).toHaveBeenCalledWith(user);
    });

    it("should omit budget context when budgeting is disabled", async () => {
      user.config.enableBudgeting = false;

      const payload = await service.buildChatPrompt(user, ChatTimeframe.threeMonths, false);

      expect(payload.contents[0]!.parts[0]!.text).not.toContain('"budget"');
      expect(budgetService.getBudgetOverview).not.toHaveBeenCalled();
    });

    it("should include an empty current-month budget when user has no budget categories", async () => {
      budgetService.getBudgetOverview.mockResolvedValue({
        year: 2026,
        month: 6,
        totalBudgeted: 0,
        totalSpent: 0,
        totalRemaining: 0,
        totalOverBudgetAmount: 0,
        items: [],
      } as any);

      const payload = await service.buildChatPrompt(user, ChatTimeframe.threeMonths, false);
      const contextData = JSON.parse(payload.contents[0]!.parts[0]!.text.split("CONTEXTUAL DATA:")[1]!);

      expect(contextData.budget).toEqual({
        month: "June 2026",
        totalBudgeted: 0,
        totalSpent: 0,
        totalRemaining: 0,
        totalOverBudgetAmount: 0,
        categories: [],
      });
    });

    it("should deduplicate daily and monthly account/holding history and preserve current snapshots", async () => {
      const now = new Date();
      const sameDay = new Date(now);
      const sameMonth = new Date(now.getFullYear(), now.getMonth(), Math.max(1, now.getDate() - 1));
      const accountHistories = [
        AccountHistory.fromPlain({ time: sameDay, balance: 1000 }),
        AccountHistory.fromPlain({ time: new Date(sameDay.getTime() - 60_000), balance: 999 }),
        AccountHistory.fromPlain({ time: sameMonth, balance: 998 }),
      ];
      const holdingHistories = [
        HoldingHistory.fromPlain({ time: sameDay, marketValue: 500 }),
        HoldingHistory.fromPlain({ time: new Date(sameDay.getTime() - 60_000), marketValue: 499 }),
        HoldingHistory.fromPlain({ time: sameMonth, marketValue: 498 }),
      ];
      vi.spyOn(AccountHistory, "find").mockResolvedValue(accountHistories as any);
      vi.spyOn(HoldingHistory, "find").mockResolvedValue(holdingHistories as any);
      vi.spyOn(Transaction, "find").mockResolvedValue([
        Transaction.fromPlain({
          id: "unmapped",
          description: "Unmapped",
          posted: new Date(),
          account: { id: "missing", name: "Missing" } as any,
        }),
      ]);
      transactionService.findSubscriptions.mockResolvedValue([
        { transaction: TestEntities.transaction, account: { id: "missing", name: "Missing" }, period: "monthly", amount: 3 } as any,
        { transaction: TestEntities.transaction, account: { id: "missing", name: "Missing" }, period: "weekly" } as any,
      ]);

      const payload = await service.buildChatPrompt(user, ChatTimeframe.oneYear, false);

      expect(payload.contents).toBeDefined();
      expect(payload.idMap).toBeDefined();
    });

    it("should build daily overview prompt", async () => {
      holdingService.getLiveHoldingPrices.mockResolvedValue([
        {
          symbol: "AAPL",
          type: MarketQuoteType.EQUITY,
          price: 200,
          change: 2,
          changePercent: 1,
          currency: "USD",
          hasMarketTimestamp: true,
          lastUpdated: "2026-11-05T21:00:00.000Z",
        } as any,
        {
          symbol: "^GSPC",
          type: MarketQuoteType.INDEX,
          marketState: MarketState.CLOSED,
          hasMarketTimestamp: true,
          lastUpdated: "2026-11-05T21:00:00.000Z",
        } as any,
      ]);

      const payload = await service.buildDailyOverviewPrompt(user);
      const contextData = JSON.parse(payload.contents[0]!.parts[0]!.text.split("CONTEXTUAL DATA:")[1]!);

      expect(contextData).not.toHaveProperty("budget");
      expect(budgetService.getBudgetOverview).not.toHaveBeenCalled();
      expect(contextData.accounts[0].liveHoldings[0].liveQuote.estimatedMarketValue).toBe(2000);
      expect(contextData.accounts[0].b).toBe("1000.00");
      expect(payload.contents[0]!.parts[0]!.text).toContain("never add holding values on top of the account balance");
    });

    it("should build holdings overview prompt", async () => {
      holdingService.getLiveHoldingPrices.mockResolvedValue([
        {
          symbol: "AAPL",
          type: MarketQuoteType.EQUITY,
          price: 200,
          change: 2,
          changePercent: 1,
          currency: "USD",
          hasMarketTimestamp: true,
          lastUpdated: "2026-11-05T21:00:00.000Z",
        } as any,
        {
          symbol: "^GSPC",
          type: MarketQuoteType.INDEX,
          marketState: MarketState.CLOSED,
          hasMarketTimestamp: true,
          lastUpdated: "2026-11-05T21:00:00.000Z",
        } as any,
      ]);

      const payload = await service.buildHoldingsOverviewPrompt(user);
      const promptText = payload.contents[0]!.parts[0]!.text;
      const contextData = JSON.parse(payload.contents[0]!.parts[0]!.text.split("CONTEXTUAL DATA:")[1]!);

      expect(contextData).not.toHaveProperty("budget");
      expect(budgetService.getBudgetOverview).not.toHaveBeenCalled();
      expect(holdingService.getLiveHoldingPrices).toHaveBeenCalledWith(["AAPL", "^GSPC"]);
      expect(contextData.liveMarketReference).toMatchObject({ source: "Yahoo Finance", marketState: MarketState.CLOSED });
      expect(contextData.accounts[0].liveHoldings[0]).toMatchObject({
        symbol: "AAPL",
        shares: 10,
        providerMarketValue: 1800,
        providerValueAsOf: "unknown",
        liveQuote: {
          comparisonStatus: "comparable",
          price: 200,
          asOf: "2026-11-05T21:00:00.000Z",
          estimatedMarketValue: 2000,
          estimatedDailyChange: 20,
        },
      });
      expect(promptText).toContain("Provider-reported market values and holding history may lag");
      expect(promptText).toContain("its movement cannot yet be assessed");
    });

    it("should flag pre-market mutual-fund NAV as uncomparable when timestamp predates latest market close", async () => {
      const fund = Holding.fromPlain({ ...TestEntities.holding, symbol: "RFKTX", shares: 2, marketValue: 63.32, currency: "USD" });
      vi.spyOn(Holding, "find").mockResolvedValue([fund]);
      holdingService.getLiveHoldingPrices.mockResolvedValue([
        {
          symbol: "RFKTX",
          type: MarketQuoteType.MUTUALFUND,
          marketState: MarketState.PRE,
          price: 31.66,
          change: -1.24,
          changePercent: -3.7,
          currency: "USD",
          hasMarketTimestamp: true,
          lastUpdated: "2026-11-05T20:59:00.000Z",
        } as any,
        {
          symbol: "^GSPC",
          type: MarketQuoteType.INDEX,
          marketState: MarketState.CLOSED,
          hasMarketTimestamp: true,
          lastUpdated: "2026-11-05T21:00:00.000Z",
        } as any,
      ]);

      const payload = await service.buildHoldingsOverviewPrompt(user);
      const contextData = JSON.parse(payload.contents[0]!.parts[0]!.text.split("CONTEXTUAL DATA:")[1]!);
      const liveHolding = contextData.accounts[0].liveHoldings[0];

      expect(liveHolding.liveQuote).toMatchObject({
        comparisonStatus: "uncomparable_nav_not_updated_since_close",
        asOf: "2026-11-05T20:59:00.000Z",
        estimatedDailyChange: null,
      });
    });

    it.each([MarketState.POST, MarketState.PRE, MarketState.PREPRE])(
      "should compare mutual-fund movement for %s when source timestamp follows market close",
      async (marketState) => {
        vi.spyOn(Holding, "find").mockResolvedValue([
          Holding.fromPlain({ ...TestEntities.holding, symbol: "RFKTX", shares: 2, marketValue: 63.32, currency: "USD" }),
        ]);
        holdingService.getLiveHoldingPrices.mockResolvedValue([
          {
            symbol: "RFKTX",
            type: MarketQuoteType.MUTUALFUND,
            marketState,
            price: 31.66,
            change: -1.24,
            changePercent: -3.7,
            currency: "USD",
            hasMarketTimestamp: true,
            lastUpdated: marketState === MarketState.POST ? "2026-11-05T23:49:05.000Z" : "2026-11-06T01:04:05.000Z",
          } as any,
          {
            symbol: "^GSPC",
            type: MarketQuoteType.INDEX,
            marketState: MarketState.CLOSED,
            hasMarketTimestamp: true,
            lastUpdated: "2026-11-05T21:00:00.000Z",
          } as any,
        ]);

        const payload = await service.buildHoldingsOverviewPrompt(user);
        const contextData = JSON.parse(payload.contents[0]!.parts[0]!.text.split("CONTEXTUAL DATA:")[1]!);

        expect(contextData.accounts[0].liveHoldings[0].liveQuote).toMatchObject({
          comparisonStatus: "comparable_after_close",
          estimatedDailyChange: -2.48,
          estimatedDailyChangePercent: -3.7,
        });
      },
    );

    it("should mark NAV uncomparable when source timestamp is missing", async () => {
      vi.spyOn(Holding, "find").mockResolvedValue([Holding.fromPlain({ ...TestEntities.holding, symbol: "RFKTX", shares: 2, currency: "USD" })]);
      holdingService.getLiveHoldingPrices.mockResolvedValue([
        {
          symbol: "RFKTX",
          type: MarketQuoteType.MUTUALFUND,
          marketState: MarketState.POST,
          price: 31.66,
          change: -1.24,
          currency: "USD",
          hasMarketTimestamp: false,
          lastUpdated: "2026-11-05T23:49:05.000Z",
        } as any,
        {
          symbol: "^GSPC",
          type: MarketQuoteType.INDEX,
          marketState: MarketState.CLOSED,
          hasMarketTimestamp: true,
          lastUpdated: "2026-11-05T21:00:00.000Z",
        } as any,
      ]);

      const payload = await service.buildHoldingsOverviewPrompt(user);
      const contextData = JSON.parse(payload.contents[0]!.parts[0]!.text.split("CONTEXTUAL DATA:")[1]!);

      expect(contextData.accounts[0].liveHoldings[0].liveQuote).toMatchObject({
        comparisonStatus: "uncomparable_missing_source_timestamp",
        asOf: null,
        estimatedDailyChange: null,
      });
    });

    it("should mark NAV uncomparable while the broad market is open", async () => {
      vi.spyOn(Holding, "find").mockResolvedValue([Holding.fromPlain({ ...TestEntities.holding, symbol: "RFKTX", shares: 2, currency: "USD" })]);
      holdingService.getLiveHoldingPrices.mockResolvedValue([
        {
          symbol: "RFKTX",
          type: MarketQuoteType.MUTUALFUND,
          marketState: MarketState.POST,
          price: 31.66,
          change: -1.24,
          currency: "USD",
          hasMarketTimestamp: true,
          lastUpdated: "2026-11-05T23:49:05.000Z",
        } as any,
        {
          symbol: "^GSPC",
          type: MarketQuoteType.INDEX,
          marketState: MarketState.REGULAR,
          hasMarketTimestamp: true,
          lastUpdated: "2026-11-05T20:00:00.000Z",
        } as any,
      ]);

      const payload = await service.buildHoldingsOverviewPrompt(user);
      const contextData = JSON.parse(payload.contents[0]!.parts[0]!.text.split("CONTEXTUAL DATA:")[1]!);

      expect(contextData.accounts[0].liveHoldings[0].liveQuote).toMatchObject({
        comparisonStatus: "uncomparable_nav_pending",
        estimatedDailyChange: null,
      });
    });

    it("should mark NAV uncomparable without a market-close reference", async () => {
      vi.spyOn(Holding, "find").mockResolvedValue([Holding.fromPlain({ ...TestEntities.holding, symbol: "RFKTX", shares: 2, currency: "USD" })]);
      holdingService.getLiveHoldingPrices.mockResolvedValue([
        {
          symbol: "RFKTX",
          type: MarketQuoteType.MUTUALFUND,
          marketState: MarketState.POST,
          price: 31.66,
          change: -1.24,
          currency: "USD",
          hasMarketTimestamp: true,
          lastUpdated: "2026-11-05T23:49:05.000Z",
        } as any,
      ]);

      const payload = await service.buildHoldingsOverviewPrompt(user);
      const contextData = JSON.parse(payload.contents[0]!.parts[0]!.text.split("CONTEXTUAL DATA:")[1]!);

      expect(contextData.accounts[0].liveHoldings[0].liveQuote).toMatchObject({
        comparisonStatus: "uncomparable_missing_market_reference",
        estimatedDailyChange: null,
      });
    });

    it("should keep building prompt when live quote lookup fails", async () => {
      holdingService.getLiveHoldingPrices.mockRejectedValue(new Error("Quote service unavailable"));

      const payload = await service.buildHoldingsOverviewPrompt(user);
      const contextData = JSON.parse(payload.contents[0]!.parts[0]!.text.split("CONTEXTUAL DATA:")[1]!);

      expect(contextData.accounts[0].liveHoldings[0].liveQuote).toMatchObject({
        comparisonStatus: "unavailable",
        estimatedMarketValue: null,
        estimatedDailyChange: null,
      });
    });

    it("should skip quote lookup when there are no holdings", async () => {
      vi.spyOn(Account, "find").mockResolvedValue([]);

      const payload = await service.buildHoldingsOverviewPrompt(user);
      const contextData = JSON.parse(payload.contents[0]!.parts[0]!.text.split("CONTEXTUAL DATA:")[1]!);

      expect(contextData.accounts).toEqual([]);
      expect(contextData.liveMarketReference).toMatchObject({ marketState: null, asOf: null });
      expect(holdingService.getLiveHoldingPrices).not.toHaveBeenCalled();
    });

    it("should use safe currency and change defaults when quote fields are missing", async () => {
      const userWithoutCurrency = { ...user, config: { ...user.config, currency: undefined } } as User;
      vi.spyOn(Holding, "find").mockResolvedValue([Holding.fromPlain({ ...TestEntities.holding, currency: "USD" })]);
      holdingService.getLiveHoldingPrices.mockResolvedValue([
        {
          symbol: "AAPL",
          type: MarketQuoteType.EQUITY,
          price: 200,
          hasMarketTimestamp: true,
          lastUpdated: "2026-11-05T21:00:00.000Z",
        } as any,
        {
          symbol: "^GSPC",
          type: MarketQuoteType.INDEX,
          marketState: MarketState.CLOSED,
          hasMarketTimestamp: true,
          lastUpdated: "2026-11-05T21:00:00.000Z",
        } as any,
      ]);

      const payload = await service.buildHoldingsOverviewPrompt(userWithoutCurrency);
      const contextData = JSON.parse(payload.contents[0]!.parts[0]!.text.split("CONTEXTUAL DATA:")[1]!);

      expect(contextData.accounts[0].liveHoldings[0].liveQuote).toMatchObject({
        comparisonStatus: "comparable",
        currency: "USD",
        estimatedMarketValue: 2000,
        estimatedDailyChange: 0,
        estimatedDailyChangePercent: null,
      });
    });

    it("should deidentify overlapping custom category names in saved chat history", async () => {
      vi.spyOn(Category, "find").mockResolvedValue([
        Category.fromPlain({ id: "food-id", name: "Food", user }),
        Category.fromPlain({ id: "food-dining-id", name: "Food & Dining", user }),
      ]);
      vi.spyOn(ChatHistory, "find").mockResolvedValue([new ChatHistory(user, "Spend in food & dining, then food; not seafood.", "user")]);

      const payload = await service.buildChatPrompt(user, ChatTimeframe.threeMonths, false);

      expect(payload.contents[1]!.parts[0]!.text).toBe("Spend in Cat_1, then Cat_0; not seafood.");
      expect(payload.idMap.get("Food")).toBe("Cat_0");
      expect(payload.idMap.get("Food & Dining")).toBe("Cat_1");
      expect(Category.find).toHaveBeenCalledWith({ where: { user: { id: user.id } } });
    });

    it("should build budget overview prompt with budget performance context", async () => {
      const payload = await service.buildBudgetOverviewPrompt(user, 2025, 2);
      const promptText = payload.contents[0]!.parts[0]!.text;
      const contextData = JSON.parse(promptText.split("CONTEXTUAL DATA:")[1]!);

      expect(budgetService.getBudgetOverview).toHaveBeenCalledWith(user, 2025, 2);
      expect(payload.idMap.get("Groceries")).toBe("Cat_0");
      expect(payload.idMap.get("Dining")).toBe("Cat_1");
      expect(promptText).not.toContain("Groceries");
      expect(promptText).not.toContain("Dining");
      expect(promptText).toContain("Cat_0");
      expect(promptText).toContain("Cat_1");
      expect(promptText).toContain('"hasLimit":false');
      expect(promptText).toContain("Analyze the full budget month, not only the last 24 hours.");
      expect(promptText).toContain("Never describe unbudgeted spending as over budget.");
      expect(contextData.categories[1].overLimit).toBe(false);
      expect(JSON.stringify(contextData)).not.toContain("budget-1");
      expect(JSON.stringify(contextData)).not.toContain("category-default-id");
    });
  });

  describe("getTimeframeDate, cleanupUserMax, and formatCleanHistory", () => {
    it("should omit the professional-advice disclaimer when CYA instructions are disabled", () => {
      const instructions = (service as unknown as { getSharedSystemInstructions: (u: User, includeCYA?: boolean) => string[] }).getSharedSystemInstructions(
        user,
        false,
      );

      expect(instructions).toContain("");
      expect(instructions).not.toContain(expect.stringContaining("educational information"));
    });

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
      expect(formatted[0]?.parts[0]?.text).toBe("Hello 1\nHello 2");
      expect(formatted[1]?.role).toBe("model");
      expect(formatted[1]?.parts[0]?.text).toBe("Rate limit hit\nSecond answer");

      const whitespace = new ChatHistory(user, "   ", "user");
      expect(
        (service as unknown as { formatCleanHistory: (h: ChatHistory[], m: Map<string, string>) => unknown[] }).formatCleanHistory([whitespace], new Map()),
      ).toEqual([]);

      const noMapMessage = new ChatHistory(user, "No map", "user");
      expect(
        (service as unknown as { formatCleanHistory: (h: ChatHistory[], m: Map<string, string> | null) => unknown[] }).formatCleanHistory([noMapMessage], null),
      ).toHaveLength(1);
    });
  });
});
