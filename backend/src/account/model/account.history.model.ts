import { Account } from "@backend/account/model/account.model";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { subDays } from "date-fns";
import { ManyToOne } from "typeorm";

/** This class provides historical tracking to accounts. Used for things like balance over time. */
@DatabaseDecorators.entity()
export class AccountHistory extends DatabaseBase {
  @ManyToOne(() => Account, (i) => i.id, { eager: true, onDelete: "CASCADE" })
  declare account: Account;

  @DatabaseDecorators.column({ nullable: false })
  declare time: Date;
  @DatabaseDecorators.numericColumn({ nullable: false })
  declare balance: number;
  @DatabaseDecorators.numericColumn({ nullable: false })
  declare availableBalance: number;

  constructor(account: Account, time: Date, balance: number, availableBalance: number) {
    super();
    this.account = account;
    this.time = time;
    this.balance = balance;
    this.availableBalance = availableBalance;
  }

  /**
   * Given an account, inserts a one day old account history intended to be used with new accounts. This will help
   *    make sure we can properly calculate when the account was added
   */
  static async insertForNewAccount(account: Account) {
    const time = subDays(new Date(), 1);
    return await new AccountHistory(account, time, 0, 0).insert();
  }
}
