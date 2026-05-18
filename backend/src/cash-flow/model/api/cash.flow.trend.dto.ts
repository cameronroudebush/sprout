import { ApiProperty } from "@nestjs/swagger";

export class CashFlowTrendStats {
  @ApiProperty({ description: "The label for the X-axis (e.g., 'Jan', 'Feb')" })
  label: string;

  @ApiProperty({ description: "Total income for the month (top bar)" })
  topValue: number;

  @ApiProperty({ description: "Total expense for the month as an absolute value (bottom bar)" })
  bottomValue: number;

  @ApiProperty({ description: "Net cash flow (Income - Expense) for the trend line" })
  trendValue: number;

  constructor(label: string, topValue: number, bottomValue: number, trendValue: number) {
    this.label = label;
    this.topValue = topValue;
    this.bottomValue = bottomValue;
    this.trendValue = trendValue;
  }
}
