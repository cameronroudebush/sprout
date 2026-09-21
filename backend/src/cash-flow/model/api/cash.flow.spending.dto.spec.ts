import { setupTests } from "@backend/test/helpers.js";
setupTests();

import {
  CashFlowSpending,
  MonthlyCategoryData,
  MonthlySpendingStats,
} from "@backend/cash-flow/model/api/cash.flow.spending.dto.js";

describe("CashFlowSpending DTO", () => {
  it("should instantiate MonthlyCategoryData", () => {
    const catData = new MonthlyCategoryData("Groceries", 150.5, "#FF0000");
    expect(catData.name).toBe("Groceries");
    expect(catData.amount).toBe(150.5);
    expect(catData.color).toBe("#FF0000");
  });

  it("should instantiate MonthlySpendingStats", () => {
    const now = new Date();
    const catData = new MonthlyCategoryData("Groceries", 150.5, "#FF0000");
    const stats = new MonthlySpendingStats("Jan 2023", now, [catData], 150.5, 150.5);
    expect(stats.monthLabel).toBe("Jan 2023");
    expect(stats.date).toBe(now);
    expect(stats.categories).toEqual([catData]);
    expect(stats.totalSpending).toBe(150.5);
    expect(stats.periodAverage).toBe(150.5);
  });

  it("should instantiate CashFlowSpending DTO", () => {
    const dto = new CashFlowSpending([], ["Groceries"]);
    expect(dto.data).toEqual([]);
    expect(dto.topCategoryNames).toEqual(["Groceries"]);
  });
});
