import { Account } from "@backend/account/model/account";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { User } from "@backend/user/model/user";
import { isSameDay, subYears } from "date-fns";
import { ManyToOne, MoreThan } from "typeorm";

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

  /**
   * Grabs the account history for all accounts related to the given user for the given time. Automatically
   *  handles only grabbing one relevant data point per day to make sure we don't have duplicate account histories.
   */
  static async getHistoryForUser(user: User, years = 1) {
    const history = await AccountHistory.findMostRecentInGroup({
      dateColumn: "time",
      partitionBy: ["accountId" as any],
      joins: ["account"],
      where: { time: MoreThan(subYears(new Date(), years)), account: { user: { id: user.id } } },
    });
    // Add today's history
    if (!history.find((x) => isSameDay(x.time, new Date()))) history.push(...(await Account.getForUser(user)).map((x) => x.toAccountHistory()));
    return history;
  }
}
