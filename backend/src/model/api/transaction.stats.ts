import { Base } from "@backend/model/base";

/** A class for the transaction status request */
export class TransactionStatsRequest extends Base {
  /** How many days to look back for this request */
  days: number;

  constructor(days: number) {
    super();
    this.days = days;
  }
}

/** A class that holds stats about transactions */
export class TransactionStats extends Base {
  totalSpend: number;
  totalIncome: number;
  averageTransactionCost: number;
  largestExpense: number;
  categories: { [category: string]: number };

  constructor(totalSpend: number, totalIncome: number, averageTransactionCost: number, largestExpense: number, categories: TransactionStats["categories"]) {
    super();
    this.totalSpend = totalSpend;
    this.totalIncome = totalIncome;
    this.averageTransactionCost = averageTransactionCost;
    this.largestExpense = largestExpense;
    this.categories = categories;
  }
}
