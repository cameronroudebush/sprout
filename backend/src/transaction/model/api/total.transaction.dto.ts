import { Base } from "@backend/core/model/base";

/** This model represents the total transactions per account and across the entire users account set. */
export class TotalTransactions extends Base {
  accounts: { [accountId: string]: number };
  total: number;

  constructor(accounts: TotalTransactions["accounts"], total: number) {
    super();
    this.accounts = accounts;
    this.total = total;
  }
}
