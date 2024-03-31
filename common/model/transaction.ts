import { Type } from "class-transformer";
import { decorate } from "ts-mixer";
import { Base, DBBase } from "./base";

export class Transaction extends DBBase {
  /** In USD */
  amount: number;
  @decorate(Type(() => Date))
  date: Date;
  account: string; // TODO

  constructor(id: number, amount: number, date: Date, account: string) {
    super(id);
    this.amount = amount;
    this.date = date;
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
