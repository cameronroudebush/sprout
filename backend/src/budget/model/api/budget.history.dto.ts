import { ApiProperty } from "@nestjs/swagger";

export class MonthlyCategoryBudgetPerformance {
  @ApiProperty({ description: "Year of performance snapshot." })
  year: number;

  @ApiProperty({ description: "Month of performance snapshot (1-12)." })
  month: number;

  @ApiProperty({ description: "Target budgeted amount." })
  budgetedAmount: number;

  @ApiProperty({ description: "Actual spent amount." })
  actualSpent: number;

  @ApiProperty({ description: "Remaining amount." })
  remaining: number;

  @ApiProperty({ description: "Indicates whether actual spending exceeded the target budget." })
  isOverBudget: boolean;

  constructor(year: number, month: number, budgetedAmount: number, actualSpent: number) {
    this.year = year;
    this.month = month;
    this.budgetedAmount = budgetedAmount;
    this.actualSpent = actualSpent;
    this.remaining = budgetedAmount - actualSpent;
    this.isOverBudget = budgetedAmount > 0 ? actualSpent > budgetedAmount : actualSpent > 0;
  }
}

export class BudgetHistoryResponseDto {
  @ApiProperty({ type: [MonthlyCategoryBudgetPerformance], description: "Historical monthly performance data points." })
  history: MonthlyCategoryBudgetPerformance[];

  constructor(history: MonthlyCategoryBudgetPerformance[]) {
    this.history = history;
  }
}
