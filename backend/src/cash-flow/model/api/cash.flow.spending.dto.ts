import { ApiProperty } from "@nestjs/swagger";

/** This class identifies a month of category data that the cash flow spending would populate. This could be like shopping or food, directly tied to a category name. */
export class MonthlyCategoryData {
  /** Name of the category */
  name: string;
  /** Total amount spent in this category for this month */
  amount: number;
  /** Color for the category. Will be a hex code. */
  color: string;

  constructor(name: string, amount: number, color: string) {
    this.name = name;
    this.amount = amount;
    this.color = color;
  }
}

/** This class defines a monthly spending amount and the category information to display on a combo chart */
export class MonthlySpendingStats {
  /** Month label */
  monthLabel: string;
  /** The date, just used for sorting */
  date: Date;

  /** A breakdown of the top categories for the month based on the request */
  @ApiProperty({ type: [MonthlyCategoryData] })
  categories: MonthlyCategoryData[];

  /** Total spending for the month */
  totalSpending: number;

  /** Average spending across the requested period (for the trend line) */
  periodAverage: number;

  constructor(monthLabel: string, date: Date, categories: MonthlyCategoryData[], totalSpending: number, periodAverage: number) {
    this.monthLabel = monthLabel;
    this.date = date;
    this.categories = categories;
    this.totalSpending = totalSpending;
    this.periodAverage = periodAverage;
  }
}

/** This class defines a cash flow model that helps show spending per month with category information related */
export class CashFlowSpending {
  @ApiProperty({ type: [MonthlySpendingStats] })
  data: MonthlySpendingStats[];

  /** The list of top categories identified across the months. */
  topCategoryNames: string[];

  constructor(data: MonthlySpendingStats[], topCategoryNames: string[]) {
    this.data = data;
    this.topCategoryNames = topCategoryNames;
  }
}
