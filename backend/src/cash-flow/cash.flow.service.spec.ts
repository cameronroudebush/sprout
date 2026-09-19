import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { CashFlowService } from "@backend/cash-flow/cash.flow.service.js";
import { Transaction } from "@backend/transaction/model/transaction.model.js";
import { Category } from "@backend/category/model/category.model.js";
import { Account } from "@backend/account/model/account.model.js";
import { AccountType } from "@backend/account/model/account.type.js";
import { AccountHistory } from "@backend/account/model/account.history.model.js";
import { TestEntities } from "@backend/test/entities.js";
import { Between } from "typeorm";

describe("CashFlowService", () => {
  let service: CashFlowService;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.clearAllMocks();
    service = new CashFlowService();
  });

  describe("calculateFlows", () => {
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
    it("should generate Sankey data with surplus node when income exceeds expenses", async () => {
      const catIn = Category.fromPlain({ id: "c1", name: "Salary", excludeFromCashFlow: false });
      const catOut = Category.fromPlain({ id: "c2", name: "Rent", parentCategoryId: "c3", excludeFromCashFlow: false });
      const catParent = Category.fromPlain({ id: "c3", name: "Housing", excludeFromCashFlow: false });

      const txIn = Transaction.fromPlain({ id: "t1", amount: 3000, category: catIn, account: TestEntities.account });
      const txOut = Transaction.fromPlain({ id: "t2", amount: -1000, category: catOut, account: TestEntities.account });

      vi.spyOn(Transaction, "find").mockResolvedValue([txIn, txOut]);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([txIn, txOut]);
      vi.spyOn(Category, "find").mockResolvedValue([catIn, catOut, catParent]);

      const sankey = await service.buildSankey(user, 2026, 6);

      expect(sankey.nodes).toContain("Salary ");
      expect(sankey.nodes).toContain("Savings / Unallocated");
      expect(sankey.links.length).toBeGreaterThan(0);
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
  });

  describe("calculateMonthlySpending", () => {
    it("should compute monthly spending history for given number of months", async () => {
      const cat = Category.fromPlain({ id: "c1", name: "Dining", excludeFromCashFlow: false });
      const tx = Transaction.fromPlain({ id: "t1", amount: -100, category: cat, account: TestEntities.account });

      vi.spyOn(Transaction, "find").mockResolvedValue([tx]);
      vi.spyOn(Transaction, "convertListToTargetCurrency").mockReturnValue([tx]);

      const spending = await service.calculateMonthlySpending(user, 3, 2);

      expect(spending.data).toHaveLength(3);
      expect(spending.topCategoryNames).toContain("Dining");
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
    it("should project loan amortization schedules for active loan accounts and skip positive balance loan", async () => {
      const loanAcc = Account.fromPlain({
        id: "loan-1",
        name: "Auto Loan",
        type: AccountType.loan,
        interestRate: 6.0,
        balance: -15000,
      });

      const positiveLoanAcc = Account.fromPlain({
        id: "loan-2",
        name: "Paid Loan",
        type: AccountType.loan,
        interestRate: 5.0,
        balance: 100,
      });

      const history1 = AccountHistory.fromPlain({ id: "h1", balance: -15500, time: new Date(2026, 4, 1) });
      const history2 = AccountHistory.fromPlain({ id: "h2", balance: -15000, time: new Date(2026, 5, 1) });

      vi.spyOn(Account, "find").mockResolvedValue([loanAcc, positiveLoanAcc]);
      vi.spyOn(AccountHistory, "find").mockResolvedValue([history2, history1]);

      const projections = await service.getLoanAmortizationProjections(user);

      expect(projections.length).toBe(1);
      expect(projections[0]!.accountId).toBe("loan-1");
      expect(projections[0]!.monthlyPayment).toBeGreaterThan(0);
    });
  });
});
