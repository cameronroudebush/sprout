import { Base } from "@backend/model/base";

/** Required content to be sent when we request transactional data */
export class TransactionRequest extends Base {
  startIndex: number;
  endIndex: number;
  category?: string;
  accountId?: string;

  constructor(startIndex: number, endIndex: number, accountId: string) {
    super();
    this.startIndex = startIndex;
    this.endIndex = endIndex;
    this.accountId = accountId;
  }
}

export class TransactionQueryRequest extends Base {
  description?: string;
  accountId?: string;
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
