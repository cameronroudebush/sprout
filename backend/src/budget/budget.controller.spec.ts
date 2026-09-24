import { setupTests } from "@backend/test/helpers";
setupTests();

import { BudgetController } from "@backend/budget/budget.controller";
import { BudgetService } from "@backend/budget/budget.service";
import { TestEntities } from "@backend/test/entities";

describe("BudgetController", () => {
  let controller: BudgetController;
  let service: any;

  beforeEach(() => {
    vi.clearAllMocks();
    service = {
      getAllBudgets: vi.fn(),
      createBudget: vi.fn(),
      updateBudget: vi.fn(),
      deleteBudget: vi.fn(),
      getBudgetOverview: vi.fn(),
      getBudgetHistory: vi.fn(),
    };
    controller = new BudgetController(service);
  });

  it("should get all budgets", async () => {
    const user = TestEntities.user;
    const budget = TestEntities.budget;
    service.getAllBudgets.mockResolvedValue([budget]);

    const result = await controller.getAllBudgets(user);
    expect(result).toEqual([budget]);
    expect(service.getAllBudgets).toHaveBeenCalledWith(user);
  });

  it("should create budget", async () => {
    const user = TestEntities.user;
    const budget = TestEntities.budget;
    const dto = { categoryId: "cat-1", amount: 200 };
    service.createBudget.mockResolvedValue(budget);

    const result = await controller.createBudget(user, dto);
    expect(result).toBe(budget);
    expect(service.createBudget).toHaveBeenCalledWith(user, dto);
  });

  it("should update budget", async () => {
    const user = TestEntities.user;
    const budget = TestEntities.budget;
    const dto = { amount: 300 };
    service.updateBudget.mockResolvedValue(budget);

    const result = await controller.updateBudget(user, "b-1", dto);
    expect(result).toBe(budget);
    expect(service.updateBudget).toHaveBeenCalledWith(user, "b-1", dto);
  });

  it("should delete budget", async () => {
    const user = TestEntities.user;
    service.deleteBudget.mockResolvedValue(undefined);

    const result = await controller.deleteBudget(user, "b-1");
    expect(result).toEqual({ success: true });
    expect(service.deleteBudget).toHaveBeenCalledWith(user, "b-1");
  });

  it("should get budget overview", async () => {
    const user = TestEntities.user;
    const overviewDto = { year: 2026, month: 6 } as any;
    service.getBudgetOverview.mockResolvedValue(overviewDto);

    const result = await controller.getBudgetOverview(user, 2026, 6);
    expect(result).toBe(overviewDto);
    expect(service.getBudgetOverview).toHaveBeenCalledWith(user, 2026, 6);
  });

  it("should get budget history", async () => {
    const user = TestEntities.user;
    const historyDto = { history: [] } as any;
    service.getBudgetHistory.mockResolvedValue(historyDto);

    const result = await controller.getBudgetHistory(user, 6, "cat-1");
    expect(result).toBe(historyDto);
    expect(service.getBudgetHistory).toHaveBeenCalledWith(user, 6, "cat-1");
  });
});
