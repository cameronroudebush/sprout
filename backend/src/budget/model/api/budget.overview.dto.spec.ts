import { setupTests } from "@backend/test/helpers";
setupTests();

import { TestEntities } from "@backend/test/entities";
import { BudgetOverviewResponseDto, CategoryBudgetOverviewItem } from "./budget.overview.dto";

describe("Budget overview DTOs", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("calculates budgeted item totals and over-budget status", () => {
    const category = TestEntities.category;
    const item = new CategoryBudgetOverviewItem(category, 100, 125, "budget-1");

    expect(item).toMatchObject({
      budgetId: "budget-1",
      category,
      budgetedAmount: 100,
      actualSpent: 125,
      remaining: -25,
      percentageUsed: 125,
      isOverBudget: true,
    });
  });

  it("handles no budget target and zero spending", () => {
    const item = new CategoryBudgetOverviewItem(TestEntities.category, 0, 0);

    expect(item).toMatchObject({
      budgetId: undefined,
      remaining: 0,
      percentageUsed: 0,
      isOverBudget: false,
    });
  });

  it("marks total over budget when spending exceeds budget even if over-budget total is zero", () => {
    const overview = new BudgetOverviewResponseDto(2025, 1, 100, 125, 0, []);

    expect(overview).toMatchObject({
      year: 2025,
      month: 1,
      totalRemaining: -25,
      totalOverBudgetAmount: 0,
      isOverBudget: true,
      items: [],
    });
  });
});
