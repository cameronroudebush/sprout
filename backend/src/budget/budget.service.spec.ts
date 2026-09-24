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

      const categoryStats = new Map<string, any>([[budget.category.id, { category: budget.category, outflow: 200 }]]);
      cashFlowService.calculateFlows.mockResolvedValue({ categoryStats } as any);

      const result = await service.getBudgetHistory(user, 3);

      expect(result.history).toHaveLength(3);
      result.history.forEach((h) => {
        expect(h.budgetedAmount).toBe(500);
        expect(h.actualSpent).toBe(200);
        expect(h.remaining).toBe(300);
        expect(h.isOverBudget).toBe(false);
      });
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

    it("should fall back to general outflow when targetBudgets list is empty", async () => {
      const user = TestEntities.user;
      user.config.enableBudgeting = true;

      vi.spyOn(Budget, "find").mockResolvedValue([]);
      const category = TestEntities.category;
      const categoryStats = new Map<string, any>([[category.id, { category, outflow: 100 }]]);
      cashFlowService.calculateFlows.mockResolvedValue({ categoryStats } as any);

      const result = await service.getBudgetHistory(user, 1);
      expect(result.history[0]?.actualSpent).toBe(100);
      expect(result.history[0]?.isOverBudget).toBe(true);
    });
  });
});
