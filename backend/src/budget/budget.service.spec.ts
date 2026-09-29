import { setupTests } from "@backend/test/helpers";
setupTests();

import { Budget } from "@backend/budget/model/budget.model";
import { CashFlowService } from "@backend/cash-flow/cash.flow.service";
import { Category } from "@backend/category/model/category.model";
import { TestEntities } from "@backend/test/entities";
import { BadRequestException, ForbiddenException, NotFoundException } from "@nestjs/common";
import { BudgetService } from "./budget.service";

describe("BudgetService", () => {
  let service: BudgetService;
  let cashFlowService: any;

  beforeEach(() => {
    vi.clearAllMocks();
    cashFlowService = {
      calculateFlows: vi.fn(),
    };
    service = new BudgetService(cashFlowService);
  });

  describe("getAllBudgets", () => {
    it("should throw ForbiddenException if enableBudgeting is false", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = false;
      await expect(service.getAllBudgets(user)).rejects.toThrow(ForbiddenException);
    });

    it("should return budgets converted to user target currency", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;
      const budget = TestEntities.budget;
      vi.spyOn(Budget, "find").mockResolvedValue([budget]);

      const result = await service.getAllBudgets(user);
      expect(result).toHaveLength(1);
      expect(result[0]!.amount).toBe(500);
      expect(Budget.find).toHaveBeenCalledWith({
        where: { user: { id: user.id } },
        relations: { category: true },
        order: { category: { name: "ASC" } },
      });
    });
  });

  describe("createBudget", () => {
    it("should throw ForbiddenException if enableBudgeting is false", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = false;
      await expect(service.createBudget(user, { categoryId: "cat-1", amount: 100 })).rejects.toThrow(ForbiddenException);
    });

    it("should throw NotFoundException if category is not found", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;
      vi.spyOn(Category, "findOne").mockResolvedValue(null);

      await expect(service.createBudget(user, { categoryId: "invalid-id", amount: 100 })).rejects.toThrow(NotFoundException);
    });

    it("should throw BadRequestException if budget already exists for category", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;
      const category = TestEntities.category;
      const budget = TestEntities.budget;

      vi.spyOn(Category, "findOne").mockResolvedValue(category);
      vi.spyOn(Budget, "findOne").mockResolvedValue(budget);

      await expect(service.createBudget(user, { categoryId: category.id, amount: 100 })).rejects.toThrow(BadRequestException);
    });

    it("should create and save new budget", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;
      const category = TestEntities.category;

      vi.spyOn(Category, "findOne").mockResolvedValue(category);
      vi.spyOn(Budget, "findOne").mockResolvedValue(null);
      vi.spyOn(Budget.prototype, "insert").mockResolvedValue({} as any);

      const dto = { categoryId: category.id, amount: 250 };
      const result = await service.createBudget(user, dto);

      expect(result.amount).toBe(250);
      expect(result.categoryId).toBe(category.id);
      expect(Budget.prototype.insert).toHaveBeenCalled();
    });
  });

  describe("updateBudget", () => {
    it("should throw ForbiddenException if enableBudgeting is false", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = false;
      await expect(service.updateBudget(user, "b-1", { amount: 300 })).rejects.toThrow(ForbiddenException);
    });

    it("should throw NotFoundException if budget is not found", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;
      vi.spyOn(Budget, "findOne").mockResolvedValue(null);

      await expect(service.updateBudget(user, "invalid-b", { amount: 300 })).rejects.toThrow(NotFoundException);
    });

    it("should update amount and save budget", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;
      const budget = TestEntities.budget;

      vi.spyOn(Budget, "findOne").mockResolvedValue(budget);
      vi.spyOn(budget, "update").mockResolvedValue(budget);

      const result = await service.updateBudget(user, budget.id, { amount: 650 });
      expect(result.amount).toBe(650);
      expect(budget.update).toHaveBeenCalled();
    });
  });

  describe("deleteBudget", () => {
    it("should throw ForbiddenException if enableBudgeting is false", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = false;
      await expect(service.deleteBudget(user, "b-1")).rejects.toThrow(ForbiddenException);
    });

    it("should throw NotFoundException if budget is not found", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;
      vi.spyOn(Budget, "findOne").mockResolvedValue(null);

      await expect(service.deleteBudget(user, "invalid-b")).rejects.toThrow(NotFoundException);
    });

    it("should remove budget when found", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;
      const budget = TestEntities.budget;

      vi.spyOn(Budget, "findOne").mockResolvedValue(budget);
      vi.spyOn(budget, "remove").mockResolvedValue(budget);

      await service.deleteBudget(user, budget.id);
      expect(budget.remove).toHaveBeenCalled();
    });
  });

  describe("getBudgetOverview", () => {
    it("should throw ForbiddenException if enableBudgeting is false", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = false;
      await expect(service.getBudgetOverview(user)).rejects.toThrow(ForbiddenException);
    });

    it("should generate budget overview with budgeted and unbudgeted categories and correctly detect overbudget status", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;
      const budget = TestEntities.budget; // budgeted 500

      const unbudgetedCategory = Category.fromPlain({
        id: "cat-unbudgeted",
        name: "Shopping",
        excludeFromCashFlow: false,
      });

      vi.spyOn(Budget, "find").mockResolvedValue([budget]);

      // Spending 600 in cat-1 (overbudget by 100) and 75 in cat-unbudgeted (overbudget by 75)
      const categoryStats = new Map<string, any>([
        [budget.category.id, { category: budget.category, outflow: 600 }],
        [unbudgetedCategory.id, { category: unbudgetedCategory, outflow: 75 }],
      ]);

      cashFlowService.calculateFlows.mockResolvedValue({
        categoryStats,
      } as any);

      const overview = await service.getBudgetOverview(user, 2026, 6);

      expect(overview.year).toBe(2026);
      expect(overview.month).toBe(6);
      expect(overview.totalBudgeted).toBe(500);
      expect(overview.totalSpent).toBe(675);
      expect(overview.totalRemaining).toBe(-175);
      expect(overview.isOverBudget).toBe(true);
      expect(overview.totalOverBudgetAmount).toBe(175);
      expect(overview.items).toHaveLength(2);

      const budgetedItem = overview.items.find((i) => i.category.id === budget.category.id);
      expect(budgetedItem).toBeDefined();
      expect(budgetedItem?.budgetedAmount).toBe(500);
      expect(budgetedItem?.actualSpent).toBe(600);
      expect(budgetedItem?.remaining).toBe(-100);
      expect(budgetedItem?.isOverBudget).toBe(true);

      const unbudgetedItem = overview.items.find((i) => i.category.id === unbudgetedCategory.id);
      expect(unbudgetedItem).toBeDefined();
      expect(unbudgetedItem?.budgetedAmount).toBe(0);
      expect(unbudgetedItem?.actualSpent).toBe(75);
      expect(unbudgetedItem?.isOverBudget).toBe(true);
    });

    it("should handle default current year and month when not provided", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;
      vi.spyOn(Budget, "find").mockResolvedValue([]);
      cashFlowService.calculateFlows.mockResolvedValue({ categoryStats: new Map() } as any);

      const overview = await service.getBudgetOverview(user);
      expect(overview.year).toBe(new Date().getFullYear());
      expect(overview.month).toBe(new Date().getMonth() + 1);
      expect(overview.isOverBudget).toBe(false);
      expect(overview.totalOverBudgetAmount).toBe(0);
    });

    it("should handle missing categories and stats, ignored spending, and tied sort values", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;

      const uncategorizedBudget = TestEntities.budget;
      uncategorizedBudget.category = undefined as any;
      const firstCategory = Category.fromPlain({ id: "category-first", name: "First", excludeFromCashFlow: false });
      const secondCategory = Category.fromPlain({ id: "category-second", name: "Second", excludeFromCashFlow: false });
      const excludedCategory = Category.fromPlain({ id: "category-excluded", name: "Excluded", excludeFromCashFlow: true });
      const emptyCategory = Category.fromPlain({ id: "category-empty", name: "Empty", excludeFromCashFlow: false });
      const firstBudget = TestEntities.budget;
      firstBudget.category = firstCategory;
      firstBudget.amount = 100;
      const secondBudget = TestEntities.budget;
      secondBudget.category = secondCategory;
      secondBudget.amount = 100;

      vi.spyOn(Budget, "find").mockResolvedValue([uncategorizedBudget, firstBudget, secondBudget]);
      cashFlowService.calculateFlows.mockResolvedValue({
        categoryStats: new Map([
          [secondCategory.id, { category: secondCategory, outflow: 20 }],
          [excludedCategory.id, { category: excludedCategory, outflow: 50 }],
          [emptyCategory.id, { category: emptyCategory, outflow: 0 }],
        ]),
      } as any);

      const overview = await service.getBudgetOverview(user, 2025, 1);

      expect(overview.totalBudgeted).toBe(200);
      expect(overview.totalSpent).toBe(20);
      expect(overview.items.map((item) => item.category.id)).toEqual([secondCategory.id, firstCategory.id]);
      expect(overview.isOverBudget).toBe(false);
    });

    it("should reject future months before calculating cash flow", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;
      const nextMonth = new Date(new Date().getFullYear(), new Date().getMonth() + 1, 1);

      await expect(service.getBudgetOverview(user, nextMonth.getFullYear(), nextMonth.getMonth() + 1)).rejects.toThrow(BadRequestException);
      expect(cashFlowService.calculateFlows).not.toHaveBeenCalled();
    });

    it("should reject invalid months", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;

      await expect(service.getBudgetOverview(user, new Date().getFullYear(), 13)).rejects.toThrow(BadRequestException);
      expect(cashFlowService.calculateFlows).not.toHaveBeenCalled();
    });
  });

  describe("getBudgetHistory", () => {
    it("should throw ForbiddenException if enableBudgeting is false", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = false;
      await expect(service.getBudgetHistory(user)).rejects.toThrow(ForbiddenException);
    });

    it("should calculate overall budget history when categoryId is omitted", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;
      const budget = TestEntities.budget;

      vi.spyOn(Budget, "find").mockResolvedValue([budget]);

      const unbudgetedCategory = Category.fromPlain({
        ...TestEntities.category,
        id: "unbudgeted-category-id",
        name: "Transit",
      });
      const excludedCategory = Category.fromPlain({
        ...TestEntities.category,
        id: "excluded-category-id",
        name: "Excluded",
        excludeFromCashFlow: true,
      });
      const categoryStats = new Map<string, any>([
        [budget.category.id, { category: budget.category, outflow: 200 }],
        [unbudgetedCategory.id, { category: unbudgetedCategory, outflow: 125 }],
        [excludedCategory.id, { category: excludedCategory, outflow: 75 }],
      ]);
      cashFlowService.calculateFlows.mockResolvedValue({ categoryStats } as any);

      const result = await service.getBudgetHistory(user, 3);

      expect(result.history).toHaveLength(3);
      result.history.forEach((h) => {
        expect(h.budgetedAmount).toBe(500);
        expect(h.actualSpent).toBe(325);
        expect(h.remaining).toBe(175);
        expect(h.isOverBudget).toBe(false);
      });
    });

    it("should anchor historical performance to the selected month", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;
      vi.spyOn(Budget, "find").mockResolvedValue([]);
      cashFlowService.calculateFlows.mockResolvedValue({ categoryStats: new Map() } as any);

      const result = await service.getBudgetHistory(user, 3, undefined, 2025, 3);

      expect(result.history.map(({ year, month }) => [year, month])).toEqual([
        [2025, 1],
        [2025, 2],
        [2025, 3],
      ]);
      expect(cashFlowService.calculateFlows).toHaveBeenNthCalledWith(1, user, 2025, 3);
      expect(cashFlowService.calculateFlows).toHaveBeenNthCalledWith(2, user, 2025, 2);
      expect(cashFlowService.calculateFlows).toHaveBeenNthCalledWith(3, user, 2025, 1);
    });

    it("should sort history chronologically across year boundaries", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;
      vi.spyOn(Budget, "find").mockResolvedValue([]);
      cashFlowService.calculateFlows.mockResolvedValue({ categoryStats: new Map() } as any);

      const result = await service.getBudgetHistory(user, 3, undefined, 2025, 2);

      expect(result.history.map(({ year, month }) => [year, month])).toEqual([
        [2024, 12],
        [2025, 1],
        [2025, 2],
      ]);
    });

    it("should reject incomplete, invalid, or future history periods", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;
      const nextMonth = new Date(new Date().getFullYear(), new Date().getMonth() + 1, 1);

      await expect(service.getBudgetHistory(user, 6, undefined, 2025)).rejects.toThrow(BadRequestException);
      await expect(service.getBudgetHistory(user, 6, undefined, 2025, 13)).rejects.toThrow(BadRequestException);
      await expect(service.getBudgetHistory(user, 6, undefined, nextMonth.getFullYear(), nextMonth.getMonth() + 1)).rejects.toThrow(BadRequestException);
      expect(cashFlowService.calculateFlows).not.toHaveBeenCalled();
    });

    it("should include unbudgeted spending when checking overall historical limits", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;
      const budget = TestEntities.budget;
      const unbudgetedCategory = Category.fromPlain({
        ...TestEntities.category,
        id: "unbudgeted-category-id",
        name: "Transit",
      });

      vi.spyOn(Budget, "find").mockResolvedValue([budget]);
      const categoryStats = new Map<string, any>([
        [budget.category.id, { category: budget.category, outflow: 200 }],
        [unbudgetedCategory.id, { category: unbudgetedCategory, outflow: 400 }],
      ]);
      cashFlowService.calculateFlows.mockResolvedValue({ categoryStats } as any);

      const result = await service.getBudgetHistory(user, 1);

      expect(result.history[0]?.budgetedAmount).toBe(500);
      expect(result.history[0]?.actualSpent).toBe(600);
      expect(result.history[0]?.remaining).toBe(-100);
      expect(result.history[0]?.isOverBudget).toBe(true);
    });

    it("should calculate category-specific budget history when categoryId is specified", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;
      const budget = TestEntities.budget;

      vi.spyOn(Budget, "findOne").mockResolvedValue(budget);

      const categoryStats = new Map<string, any>([[budget.category.id, { category: budget.category, outflow: 600 }]]);
      cashFlowService.calculateFlows.mockResolvedValue({ categoryStats } as any);

      const result = await service.getBudgetHistory(user, 2, budget.category.id);

      expect(result.history).toHaveLength(2);
      result.history.forEach((h) => {
        expect(h.budgetedAmount).toBe(500);
        expect(h.actualSpent).toBe(600);
        expect(h.isOverBudget).toBe(true);
      });
    });

    it("should handle history when no budget exists for specified category", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;

      vi.spyOn(Budget, "findOne").mockResolvedValue(null);
      cashFlowService.calculateFlows.mockResolvedValue({ categoryStats: new Map() } as any);

      const result = await service.getBudgetHistory(user, 2, "non-existent-cat");

      expect(result.history).toHaveLength(2);
      result.history.forEach((h) => {
        expect(h.budgetedAmount).toBe(0);
        expect(h.actualSpent).toBe(0);
        expect(h.isOverBudget).toBe(false);
      });
    });

    it("should show general outflow without marking it over budget when no limits exist", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;

      vi.spyOn(Budget, "find").mockResolvedValue([]);
      const category = TestEntities.category;
      const categoryStats = new Map<string, any>([[category.id, { category, outflow: 100 }]]);
      cashFlowService.calculateFlows.mockResolvedValue({ categoryStats } as any);

      const result = await service.getBudgetHistory(user, 1);
      expect(result.history[0]?.actualSpent).toBe(100);
      expect(result.history[0]?.isOverBudget).toBe(false);
    });
  });
});
