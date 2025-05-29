import { Type } from "class-transformer";
import { decorate } from "ts-mixer";
import { Account } from "./account";
import { Base, DBBase } from "./base";

export class Transaction extends DBBase {
  /** In the currency of the account */
  amount: number;
  description: string;
  pending = false;
  category: string;

  /** The date this transaction posted */
  @decorate(Type(() => Date))
  posted: Date;

  /** The account this transaction belongs to */
  account: Account;

  constructor(amount: number, posted: Date, description: string, category: string, account: Account) {
    super();
    this.amount = amount;
    this.posted = posted;
    this.description = description;
    this.category = category;
    this.account = account;
  }
}

/** Required content to be sent when we request transactional data */
export class TransactionRequest extends Base {
  startIndex: number;
  endIndex: number;

  constructor(startIndex: number, endIndex: number) {
    super();
    this.startIndex = startIndex;
    this.endIndex = endIndex;
  }
}
