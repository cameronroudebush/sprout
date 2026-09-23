import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { AccountHistory } from "@backend/account/model/account.history.model.js";
import { Account } from "@backend/account/model/account.model.js";
import { AccountType } from "@backend/account/model/account.type.js";
import { CashFlowService } from "@backend/cash-flow/cash.flow.service.js";
import { Category } from "@backend/category/model/category.model.js";
import { TestEntities } from "@backend/test/entities.js";
import { Transaction } from "@backend/transaction/model/transaction.model.js";
import { subDays } from "date-fns";
import { Between } from "typeorm";

describe("CashFlowService", () => {
  let service: CashFlowService;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.restoreAllMocks();
    service = new CashFlowService();
  });

  describe("calculateFlows", () => {
    it("should calculate cash flows for January (month 1, decremented to 0)", async () => {
      const categoryIn = Category.fromPlain({ id: "cat-in", name: "Salary", excludeFromCashFlow: false });
      const txIncome = Transaction.fromPlain({ id: "t1", amount: 2000, category: categoryIn, account: TestEntities.account, pending: false });

      vi.spyOn(Transaction, "find").mockResolvedValue([txIncome]);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([txIncome]);

      const res = await service.calculateFlows(user, 2026, 1);

      expect(res.totalIncome).toBe(2000);
    });

    it("should skip setting largestExpense when expense category has excludeFromCashFlow set to true", async () => {
      const categoryExcluded = Category.fromPlain({ id: "cat-ex", name: "Transfer", excludeFromCashFlow: true });
      const txExcludedExpense = Transaction.fromPlain({ id: "t-ex", amount: -5000, category: categoryExcluded, account: TestEntities.account, pending: false });

      vi.spyOn(Transaction, "find").mockResolvedValue([txExcludedExpense]);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([txExcludedExpense]);

      const res = await service.calculateFlows(user, 2026, 6);

      expect(res.largestExpense).toBeUndefined();
    });

    it("should skip transactions without an associated category", async () => {
      const txNoCategory = Transaction.fromPlain({ id: "t-no-cat", amount: -100, account: TestEntities.account, pending: false });

      vi.spyOn(Transaction, "find").mockResolvedValue([txNoCategory]);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([txNoCategory]);

      const res = await service.calculateFlows(user, 2026, 6);

      expect(res.filteredTransactions).toHaveLength(0);
      expect(res.totalExpense).toBe(0);
    });

    it("should calculate cash flows for a specific month and year", async () => {
      const categoryIn = Category.fromPlain({ id: "cat-in", name: "Salary", excludeFromCashFlow: false });
      const categoryOut = Category.fromPlain({ id: "cat-out", name: "Groceries", excludeFromCashFlow: false });
      const categoryExcluded = Category.fromPlain({ id: "cat-ex", name: "Transfer", excludeFromCashFlow: true });

      const txIncome = Transaction.fromPlain({ id: "t1", amount: 2000, category: categoryIn, account: TestEntities.account, pending: false });
      const txExpense = Transaction.fromPlain({ id: "t2", amount: -1500, category: categoryOut, account: TestEntities.account, pending: false });
      const txExcluded = Transaction.fromPlain({ id: "t3", amount: -300, category: categoryExcluded, account: TestEntities.account, pending: false });

      vi.spyOn(Transaction, "find").mockResolvedValue([txIncome, txExpense, txExcluded]);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([txIncome, txExpense, txExcluded]);

      const res = await service.calculateFlows(user, 2026, 6);

      expect(res.totalIncome).toBe(2000);
      expect(res.totalExpense).toBe(1500);
      expect(res.largestExpense).toBe(txExpense);
      expect(res.filteredTransactions).toHaveLength(2);
    });

    it("should calculate cash flows with customRange FindOperator", async () => {
      vi.spyOn(Transaction, "find").mockResolvedValue([]);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([]);

      const customRange = Between(new Date(2026, 0, 1), new Date(2026, 11, 31));
      const res = await service.calculateFlows(user, undefined, undefined, undefined, undefined, customRange);

      expect(res.totalIncome).toBe(0);
    });

    it("should calculate cash flows for a full year when month is omitted", async () => {
      vi.spyOn(Transaction, "find").mockResolvedValue([]);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([]);

      const res = await service.calculateFlows(user, 2026);

      expect(res.totalIncome).toBe(0);
      expect(res.totalExpense).toBe(0);
    });

    it("should calculate cash flows for a specific day when day is provided", async () => {
      vi.spyOn(Transaction, "find").mockResolvedValue([]);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([]);

      const res = await service.calculateFlows(user, 2026, 6, 15, "acc-123");

      expect(res.totalIncome).toBe(0);
      expect(res.totalExpense).toBe(0);
    });
  });

  describe("buildSankey", () => {
    it("should handle link value <= 0.01 early exit and update existing links", async () => {
      const catIn = Category.fromPlain({ id: "c1", name: "Salary", excludeFromCashFlow: false });
      const txIn1 = Transaction.fromPlain({ id: "t1", amount: 1000, category: catIn, account: TestEntities.account });
      const txIn2 = Transaction.fromPlain({ id: "t2", amount: 500, category: catIn, account: TestEntities.account });
      const txMicro = Transaction.fromPlain({ id: "t3", amount: 0.005, category: catIn, account: TestEntities.account });

      vi.spyOn(Transaction, "find").mockResolvedValue([txIn1, txIn2, txMicro]);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([txIn1, txIn2, txMicro]);
      vi.spyOn(Category, "find").mockResolvedValue([catIn]);

      const sankey = await service.buildSankey(user, 2026, 6);

      expect(sankey.nodes).toContain("Salary ");
    });

    it("should generate Sankey data with surplus node when income exceeds expenses and walk up category tree", async () => {
      const catParent = Category.fromPlain({ id: "c3", name: "Housing", excludeFromCashFlow: false });
      const catOut = Category.fromPlain({ id: "c2", name: "Rent", parentCategoryId: "c3", excludeFromCashFlow: false });
      const catIn = Category.fromPlain({ id: "c1", name: "Salary", excludeFromCashFlow: false });
      const catFlowThrough = Category.fromPlain({ id: "c4", name: "Flow Through", excludeFromCashFlow: false });

      const txIn = Transaction.fromPlain({ id: "t1", amount: 3000, category: catIn, account: TestEntities.account });
      const txOut = Transaction.fromPlain({ id: "t2", amount: -1000, category: catOut, account: TestEntities.account });
      const txFT = Transaction.fromPlain({ id: "t3", amount: 500, category: catFlowThrough, account: TestEntities.account });

      vi.spyOn(Transaction, "find").mockResolvedValue([txIn, txOut, txFT]);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([txIn, txOut, txFT]);
      vi.spyOn(Category, "find").mockResolvedValue([catIn, catOut, catParent, catFlowThrough]);

      const sankey = await service.buildSankey(user, 2026, 6);

      expect(sankey.nodes).toContain("Salary ");
      expect(sankey.nodes).toContain("Housing");
      expect(sankey.nodes).toContain("Savings / Unallocated");
      expect(sankey.links.length).toBeGreaterThan(0);
    });

    it("should handle missing parent category in map during path traversal", async () => {
      const catIn = Category.fromPlain({ id: "c1", name: "Salary", excludeFromCashFlow: false });
      const catOut = Category.fromPlain({ id: "c2", name: "Rent", parentCategoryId: "c-missing", excludeFromCashFlow: false });

      const txIn = Transaction.fromPlain({ id: "t1", amount: 3000, category: catIn, account: TestEntities.account });
      const txOut = Transaction.fromPlain({ id: "t2", amount: -1000, category: catOut, account: TestEntities.account });

      vi.spyOn(Transaction, "find").mockResolvedValue([txIn, txOut]);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([txIn, txOut]);
      vi.spyOn(Category, "find").mockResolvedValue([catIn, catOut]);

      const sankey = await service.buildSankey(user, 2026, 6);
      expect(sankey.nodes).toContain("Rent");
    });

    it("should generate Sankey data with deficit node when expenses exceed income", async () => {
      const catOut = Category.fromPlain({ id: "c2", name: "Shopping", excludeFromCashFlow: false });
      const txOut = Transaction.fromPlain({ id: "t2", amount: -2000, category: catOut, account: TestEntities.account });

      vi.spyOn(Transaction, "find").mockResolvedValue([txOut]);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([txOut]);
      vi.spyOn(Category, "find").mockResolvedValue([catOut]);

      const sankey = await service.buildSankey(user, 2026, 6);

      expect(sankey.nodes).toContain("Deficit");
    });

    it("should omit surplus and deficit nodes when income equals expense", async () => {
      const category = Category.fromPlain({ id: "balanced", name: "Balanced", excludeFromCashFlow: false });
      const transactions = [
        Transaction.fromPlain({ id: "balanced-income", amount: 100, category, account: TestEntities.account }),
        Transaction.fromPlain({ id: "balanced-expense", amount: -100, category, account: TestEntities.account }),
      ];
      vi.spyOn(Transaction, "find").mockResolvedValue(transactions);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue(transactions);
      vi.spyOn(Category, "find").mockResolvedValue([category]);

      const sankey = await service.buildSankey(user, 2026, 6);

      expect(sankey.nodes).not.toContain("Savings / Unallocated");
      expect(sankey.nodes).not.toContain("Deficit");
    });

    it("should ignore self-referential expense links and merge duplicate links", async () => {
      const flowThrough = Category.fromPlain({ id: "flow-through-expense", name: "Flow Through", excludeFromCashFlow: false });
      const foodOne = Category.fromPlain({ id: "food-one", name: "Food", excludeFromCashFlow: false });
      const foodTwo = Category.fromPlain({ id: "food-two", name: "Food", excludeFromCashFlow: false });
      const transactions = [
        Transaction.fromPlain({ id: "ft-expense", amount: -10, category: flowThrough, account: TestEntities.account }),
        Transaction.fromPlain({ id: "food-one-expense", amount: -20, category: foodOne, account: TestEntities.account }),
        Transaction.fromPlain({ id: "food-two-expense", amount: -30, category: foodTwo, account: TestEntities.account }),
      ];
      vi.spyOn(Transaction, "find").mockResolvedValue(transactions);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue(transactions);
      vi.spyOn(Category, "find").mockResolvedValue([flowThrough, foodOne, foodTwo]);

      const sankey = await service.buildSankey(user, 2026, 6);

      expect(sankey.links.find((link) => link.source === "Flow Through" && link.target === "Flow Through")).toBeUndefined();
      expect(sankey.links.find((link) => link.source === "Flow Through" && link.target === "Food")?.value).toBe(50);
    });
  });

  describe("calculateMonthlySpending", () => {
    it("should compute monthly spending history and sort Other category correctly", async () => {
      const catIn = Category.fromPlain({ id: "c-in", name: "Income", excludeFromCashFlow: false });
      const catTop = Category.fromPlain({ id: "c1", name: "Dining", excludeFromCashFlow: false });
      const catOther1 = Category.fromPlain({ id: "c2", name: "Misc1", excludeFromCashFlow: false });
      const catOther2 = Category.fromPlain({ id: "c3", name: "Misc2", excludeFromCashFlow: false });

      const txIn = Transaction.fromPlain({ id: "t1", amount: 500, category: catIn, account: TestEntities.account });
      const txTop = Transaction.fromPlain({ id: "t2", amount: -100, category: catTop, account: TestEntities.account });
      const txOther1 = Transaction.fromPlain({ id: "t3", amount: -50, category: catOther1, account: TestEntities.account });
      const txOther2 = Transaction.fromPlain({ id: "t4", amount: -25, category: catOther2, account: TestEntities.account });

      vi.spyOn(Transaction, "find").mockResolvedValue([txIn, txTop, txOther1, txOther2]);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([txIn, txTop, txOther1, txOther2]);

      const spending = await service.calculateMonthlySpending(user, 1, 1);

      expect(spending.data).toHaveLength(1);
      expect(spending.topCategoryNames).toContain("Dining");
      const monthData = spending.data[0]!;
      expect(monthData.categories.some((c) => c.name === "Other")).toBe(true);
      // Ensure Other is placed last
      expect(monthData.categories[monthData.categories.length - 1]!.name).toBe("Other");
    });

    it("should sort Other when it appears before a named category", async () => {
      const other = Category.fromPlain({ id: "other-first", name: "Other Source", excludeFromCashFlow: false });
      const top = Category.fromPlain({ id: "top-second", name: "Top Source", excludeFromCashFlow: false });
      const transactions = [
        Transaction.fromPlain({ id: "other-expense", amount: -50, category: other, account: TestEntities.account }),
        Transaction.fromPlain({ id: "top-expense", amount: -100, category: top, account: TestEntities.account }),
      ];
      vi.spyOn(Transaction, "find").mockResolvedValue(transactions);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue(transactions);

      const spending = await service.calculateMonthlySpending(user, 1, 1);

      expect(spending.data[0]!.categories.map((category) => category.name)).toEqual(["Top Source", "Other"]);
    });

    it("should sort multiple monthly results chronologically", async () => {
      vi.spyOn(Transaction, "find").mockResolvedValue([]);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([]);

      const spending = await service.calculateMonthlySpending(user, 2, 2);

      expect(spending.data).toHaveLength(2);
      expect(spending.data[0]!.date.getTime()).toBeLessThan(spending.data[1]!.date.getTime());
    });
  });

  describe("getSpendingTimeline", () => {
    it("should compute daily accumulated spending timeline for a month", async () => {
      vi.spyOn(Transaction, "find").mockResolvedValue([]);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([]);

      const timeline = await service.getSpendingTimeline(user, 2026, 6);

      expect(timeline.length).toBe(30);
    });

    it("should compute monthly accumulated spending timeline for a year", async () => {
      vi.spyOn(Transaction, "find").mockResolvedValue([]);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([]);

      const timeline = await service.getSpendingTimeline(user, 2026);

      expect(timeline.length).toBe(12);
    });
  });

  describe("getDailySpendingMap", () => {
    it("should map daily net spending items for a given month", async () => {
      const cat = Category.fromPlain({ id: "c1", name: "Food", excludeFromCashFlow: false });
      const tx = Transaction.fromPlain({ id: "t1", amount: -50, category: cat, account: TestEntities.account });

      vi.spyOn(Transaction, "find").mockResolvedValue([tx]);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([tx]);

      const result = await service.getDailySpendingMap(user, 2026, 6);

      expect(result.spending).toBeDefined();
    });
  });

  describe("getLoanAmortizationProjections", () => {
    it("should skip positive or zero balance loan accounts", async () => {
      const positiveLoan = Account.fromPlain({
        id: "loan-pos",
        name: "Positive Loan",
        type: AccountType.loan,
        interestRate: 5.0,
        balance: 1000,
      });

      vi.spyOn(Account, "find").mockResolvedValue([positiveLoan]);

      const projections = await service.getLoanAmortizationProjections(user);

      expect(projections).toHaveLength(0);
    });

    it("should skip loan account if histories exist but calculated monthly payment is zero or negative", async () => {
      const loanAcc = Account.fromPlain({
        id: "loan-zero",
        name: "Zero Payment Loan",
        type: AccountType.loan,
        interestRate: 5.0,
        balance: -1000,
      });

      const now = new Date();
      const prevMonth = subDays(now, 35);

      // Account balance worsened / no payments made
      const history1 = AccountHistory.fromPlain({ id: "h1", balance: -900, time: prevMonth });
      const history2 = AccountHistory.fromPlain({ id: "h2", balance: -1000, time: now });

      vi.spyOn(Account, "find").mockResolvedValue([loanAcc]);
      vi.spyOn(AccountHistory, "find").mockResolvedValue([history2, history1]);

      const projections = await service.getLoanAmortizationProjections(user);

      expect(projections).toHaveLength(0);
    });

    it("should project loan amortization schedules for active loan accounts and pop current month if <= last month", async () => {
      const loanAcc = Account.fromPlain({
        id: "loan-1",
        name: "Auto Loan",
        type: AccountType.loan,
        interestRate: 6.0,
        balance: -15000,
      });

      const now = new Date();
      const prevMonth = subDays(now, 35);
      const prevPrevMonth = subDays(now, 65);

      const history1 = AccountHistory.fromPlain({ id: "h1", balance: -16000, time: prevPrevMonth });
      const history2 = AccountHistory.fromPlain({ id: "h2", balance: -15000, time: prevMonth });
      const history3 = AccountHistory.fromPlain({ id: "h3", balance: -15500, time: now });

      vi.spyOn(Account, "find").mockResolvedValue([loanAcc]);
      vi.spyOn(AccountHistory, "find").mockResolvedValue([history3, history2, history1]);

      const projections = await service.getLoanAmortizationProjections(user);

      expect(projections).toBeDefined();
      expect(projections.length).toBeGreaterThan(0);
    });

    it("should calculate a positive payment from current and prior month balances", async () => {
      const loanAcc = Account.fromPlain({
        id: "loan-payment",
        name: "Payment Loan",
        type: AccountType.loan,
        interestRate: 6,
        balance: -800,
      });
      const now = new Date();
      const previous = subDays(now, 35);
      const currentHistory = AccountHistory.fromPlain({ id: "current", balance: -800, time: now });
      const previousHistory = AccountHistory.fromPlain({ id: "previous", balance: -1000, time: previous });

      vi.spyOn(Account, "find").mockResolvedValue([loanAcc]);
      vi.spyOn(AccountHistory, "find").mockResolvedValue([currentHistory, previousHistory]);

      const projections = await service.getLoanAmortizationProjections(user);

      expect(projections).toHaveLength(1);
      expect(projections[0]!.dataPoints.length).toBeGreaterThan(1);
    });

    it("should ignore non-positive inferred payments while retaining positive payments", async () => {
      const loanAcc = Account.fromPlain({
        id: "loan-mixed-payments",
        name: "Mixed Payment Loan",
        type: AccountType.loan,
        interestRate: 6,
        balance: -900,
      });
      const now = new Date();
      const monthAgo = subDays(now, 35);
      const twoMonthsAgo = subDays(now, 65);
      const histories = [
        AccountHistory.fromPlain({ id: "mixed-current", balance: -900, time: now }),
        AccountHistory.fromPlain({ id: "mixed-middle", balance: -1100, time: monthAgo }),
        AccountHistory.fromPlain({ id: "mixed-old", balance: -1000, time: twoMonthsAgo }),
      ];

      vi.spyOn(Account, "find").mockResolvedValue([loanAcc]);
      vi.spyOn(AccountHistory, "find").mockResolvedValue(histories);

      const projections = await service.getLoanAmortizationProjections(user);

      expect(projections).toHaveLength(1);
      expect(projections[0]!.monthlyPayment).toBeGreaterThan(0);
    });

    it("should retain current month projection when estimated payment day is in the future", async () => {
      vi.useFakeTimers({ now: new Date("2026-01-10T12:00:00Z") });
      try {
        const loanAcc = Account.fromPlain({
          id: "loan-future-payment",
          name: "Future Payment Loan",
          type: AccountType.loan,
          interestRate: 6,
          balance: -800,
        });
        const current = new Date("2026-01-10T12:00:00Z");
        const previous = new Date("2025-12-20T12:00:00Z");
        const older = new Date("2025-11-15T12:00:00Z");
        vi.spyOn(Account, "find").mockResolvedValue([loanAcc]);
        vi.spyOn(AccountHistory, "find").mockResolvedValue([
          AccountHistory.fromPlain({ id: "future-current", balance: -800, time: current }),
          AccountHistory.fromPlain({ id: "future-previous", balance: -900, time: previous }),
          AccountHistory.fromPlain({ id: "future-older", balance: -1100, time: older }),
        ]);

        const projections = await service.getLoanAmortizationProjections(user);

        expect(projections[0]!.dataPoints[1]!.date.getMonth()).toBe(0);
      } finally {
        vi.useRealTimers();
      }
    });

    describe("calculateFlows", () => {
      it("should allow pending transactions when includePending is true", async () => {
        const spyFind = vi.spyOn(Transaction, "find").mockResolvedValue([]);
        vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([]);

        await service.calculateFlows(user, 2026, 6, undefined, undefined, undefined, true);

        expect(spyFind).toHaveBeenCalledWith(
          expect.objectContaining({
            where: expect.not.objectContaining({ pending: false }),
          }),
        );
      });
    });

    describe("buildSankey", () => {
      it("should handle income category named 'Flow Through' and avoid self-referential links", async () => {
        const catFlowThroughIn = Category.fromPlain({ id: "c-ft", name: "Flow Through", excludeFromCashFlow: false });
        const tx = Transaction.fromPlain({ id: "t1", amount: 1000, category: catFlowThroughIn, account: TestEntities.account });

        vi.spyOn(Transaction, "find").mockResolvedValue([tx]);
        vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([tx]);
        vi.spyOn(Category, "find").mockResolvedValue([catFlowThroughIn]);

        const sankey = await service.buildSankey(user, 2026, 6);

        expect(sankey.nodes).toContain("Flow Through  ");
      });
    });

    describe("calculateMonthlySpending", () => {
      it("should skip categories with outflow <= 0 and sort non-Other categories by amount", async () => {
        const catIn = Category.fromPlain({ id: "c-in", name: "Salary", excludeFromCashFlow: false });
        const catA = Category.fromPlain({ id: "cA", name: "CatA", excludeFromCashFlow: false });
        const catB = Category.fromPlain({ id: "cB", name: "CatB", excludeFromCashFlow: false });
        const catC = Category.fromPlain({ id: "cC", name: "CatC", excludeFromCashFlow: false });

        const txIncome = Transaction.fromPlain({ id: "t0", amount: 1000, category: catIn, account: TestEntities.account });
        const txA = Transaction.fromPlain({ id: "t1", amount: -100, category: catA, account: TestEntities.account });
        const txB = Transaction.fromPlain({ id: "t2", amount: -300, category: catB, account: TestEntities.account });
        const txC = Transaction.fromPlain({ id: "t3", amount: -50, category: catC, account: TestEntities.account });

        vi.spyOn(Transaction, "find").mockResolvedValue([txIncome, txA, txB, txC]);
        vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([txIncome, txA, txB, txC]);

        // categoriesLimit = 2 -> CatB ($300) and CatA ($100) are top, CatC ($50) becomes Other
        const spending = await service.calculateMonthlySpending(user, 1, 2);

        const monthData = spending.data[0]!;
        expect(monthData.categories.map((c) => c.name)).toEqual(["CatB", "CatA", "Other"]);
      });
    });

    describe("getSpendingTimeline", () => {
      it("should accumulate running totals across all 12 months for yearly mode", async () => {
        const cat = Category.fromPlain({ id: "c1", name: "Groceries", excludeFromCashFlow: false });
        const tx = Transaction.fromPlain({ id: "t1", amount: -100, category: cat, account: TestEntities.account });

        vi.spyOn(Transaction, "find").mockResolvedValue([tx]);
        vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([tx]);

        const timeline = await service.getSpendingTimeline(user, 2026);

        expect(timeline).toHaveLength(12);
        expect(timeline[0]!.value).toBe(100);
        expect(timeline[11]!.value).toBe(1200);
      });
    });

    describe("getDailySpendingMap", () => {
      it("should omit days where netFlow is zero", async () => {
        const cat = Category.fromPlain({ id: "c1", name: "Transfer", excludeFromCashFlow: false });
        const txIn = Transaction.fromPlain({ id: "t1", amount: 100, category: cat, account: TestEntities.account });
        const txOut = Transaction.fromPlain({ id: "t2", amount: -100, category: cat, account: TestEntities.account });

        vi.spyOn(Transaction, "find").mockResolvedValue([txIn, txOut]);
        vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([txIn, txOut]);

        const result = await service.getDailySpendingMap(user, 2026, 6);

        expect(result.spending).toHaveLength(0);
      });
    });

    describe("getLoanAmortizationProjections", () => {
      it("should skip loan accounts with no history records", async () => {
        const loanAcc = Account.fromPlain({
          id: "loan-no-history",
          name: "No History Loan",
          type: AccountType.loan,
          interestRate: 5.0,
          balance: -5000,
        });

        vi.spyOn(Account, "find").mockResolvedValue([loanAcc]);
        vi.spyOn(AccountHistory, "find").mockResolvedValue([]);

        const projections = await service.getLoanAmortizationProjections(user);

        expect(projections).toHaveLength(0);
      });

      it("should increment targetMonth when estimated payment day is on or before current day of month", async () => {
        const now = new Date();

        const loanAcc = Account.fromPlain({
          id: "loan-passed-date",
          name: "Past Payment Date Loan",
          type: AccountType.loan,
          interestRate: 6.0,
          balance: -1000,
        });

        const prevMonth = subDays(now, 35);

        // Payment jump occurred on day 1 (which is <= currentDay)
        const pastPaymentDate = new Date(prevMonth.getFullYear(), prevMonth.getMonth(), 1, 12, 0, 0);
        const pastPrevPaymentDate = new Date(prevMonth.getFullYear(), prevMonth.getMonth() - 1, 1, 12, 0, 0);

        const history1 = AccountHistory.fromPlain({ id: "h1", balance: -2000, time: pastPrevPaymentDate });
        const history2 = AccountHistory.fromPlain({ id: "h2", balance: -1000, time: pastPaymentDate });

        vi.spyOn(Account, "find").mockResolvedValue([loanAcc]);
        vi.spyOn(AccountHistory, "find").mockResolvedValue([history2, history1]);

        const projections = await service.getLoanAmortizationProjections(user);

        expect(projections).toHaveLength(1);
        expect(projections[0]!.dataPoints.length).toBeGreaterThan(1);
      });
    });
  });
});
