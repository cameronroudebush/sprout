import { Category } from "@backend/category/model/category.model";
import { ApiProperty } from "@nestjs/swagger";

export class CategoryBudgetOverviewItem {
  @ApiProperty({ description: "The ID of the budget, if configured for this category.", required: false })
  budgetId?: string;

  @ApiProperty({ description: "The category for this budget line item." })
  category: Category;

  @ApiProperty({ description: "The target budgeted amount for the month." })
  budgetedAmount: number;

  @ApiProperty({ description: "The actual spent amount for the month." })
  actualSpent: number;

  @ApiProperty({ description: "The remaining budget amount for the month (budgetedAmount - actualSpent)." })
  remaining: number;

  @ApiProperty({ description: "The percentage of budget used (0 to 100+)." })
  percentageUsed: number;

  @ApiProperty({ description: "Indicates whether actual spending exceeded the budget target for this category." })
  isOverBudget: boolean;

  constructor(category: Category, budgetedAmount: number, actualSpent: number, budgetId?: string) {
    this.budgetId = budgetId;
    this.category = category;
    this.budgetedAmount = budgetedAmount;
    this.actualSpent = actualSpent;
    this.remaining = budgetedAmount - actualSpent;
    this.percentageUsed = budgetedAmount > 0 ? (actualSpent / budgetedAmount) * 100 : 0;
    this.isOverBudget = budgetedAmount > 0 ? actualSpent > budgetedAmount : actualSpent > 0;
  }
}

export class BudgetOverviewResponseDto {
  @ApiProperty({ description: "The year of this budget overview." })
  year: number;

  @ApiProperty({ description: "The month of this budget overview (1-12)." })
  month: number;

  @ApiProperty({ description: "Total budgeted amount across all categories for the month." })
  totalBudgeted: number;

  @ApiProperty({ description: "Total actual spent amount across budgeted categories for the month." })
  totalSpent: number;

  @ApiProperty({ description: "Total remaining budget amount across all categories." })
  totalRemaining: number;

  @ApiProperty({ description: "Indicates whether total spending across budgeted categories exceeded the total budget limit." })
  isOverBudget: boolean;

  @ApiProperty({ description: "Total amount by which spending exceeded budget limits." })
  totalOverBudgetAmount: number;

  @ApiProperty({ type: [CategoryBudgetOverviewItem], description: "List of category budget overview items." })
  items: CategoryBudgetOverviewItem[];

  constructor(year: number, month: number, totalBudgeted: number, totalSpent: number, totalOverBudgetAmount: number, items: CategoryBudgetOverviewItem[]) {
    this.year = year;
    this.month = month;
    this.totalBudgeted = totalBudgeted;
    this.totalSpent = totalSpent;
    this.totalRemaining = totalBudgeted - totalSpent;
    this.totalOverBudgetAmount = totalOverBudgetAmount;
    this.isOverBudget = totalOverBudgetAmount > 0 || (totalBudgeted > 0 && totalSpent > totalBudgeted);
    this.items = items;
  }
}
