import { Base } from "@backend/model/base";
import { Category } from "@backend/model/category";

/** Required content to be sent when we request transactional data */
export class TransactionRequest extends Base {
  startIndex?: number;
  endIndex?: number;
  /**
   * A specific category you want data for. If you pass unknown here, we'll return all categories matching
   *  `null`. If this is not populated, we'll simply return all categories.
   */
  category?: Category | "Unknown";
  /** An account ID you want transactions specifically for */
  accountId?: string;
  /** Description to request. We'll use `Like` within the query so it will find anything similar. */
  description?: string;

  constructor(startIndex?: number, endIndex?: number, accountId?: string, description?: string) {
    super();
    this.startIndex = startIndex;
    this.endIndex = endIndex;
    this.accountId = accountId;
    this.description = description;
  }
}

export class TotalTransactions extends Base {
  accounts: { [accountId: string]: number };
  total: number;

  constructor(accounts: TotalTransactions["accounts"], total: number) {
    super();
    this.accounts = accounts;
    this.total = total;
  }
}
