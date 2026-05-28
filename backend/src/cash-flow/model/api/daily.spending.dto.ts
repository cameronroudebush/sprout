import { ApiProperty } from "@nestjs/swagger";

export class DailySpendingItem {
  @ApiProperty({ description: "The day of the month (1-31).", example: 15 })
  day: number;

  @ApiProperty({ description: "The total spending amount for this specific day.", example: 1450.0 })
  amount: number;

  constructor(day: number, amount: number) {
    this.day = day;
    this.amount = amount;
  }
}

export class DailySpendingCalendarResponseDTO {
  @ApiProperty({
    type: [DailySpendingItem],
    description: "List of days containing spending metrics for the target month.",
  })
  spending: DailySpendingItem[];

  constructor(spending: DailySpendingItem[]) {
    this.spending = spending;
  }
}
