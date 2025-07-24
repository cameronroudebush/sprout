import { DatabaseDecorators } from "@backend/database/decorators";
import { Account } from "@backend/model/account";
import { DatabaseBase } from "@backend/model/database.base";
import { User } from "@backend/model/user";
import { FindManyOptions, ManyToOne } from "typeorm";

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

  /** Returns all distinct account histories by user. This means only one account history per day, per account. */
  static async getDistinctHistoryByUser(user: User, opts?: FindManyOptions<AccountHistory>): Promise<AccountHistory[]> {
    const repository = this.getRepository();

    const subQuery = repository
      .createQueryBuilder("ah_sub")
      .select("ah_sub.account.id", "accountId")
      .addSelect("MAX(ah_sub.time)", "maxTime")
      .innerJoin("ah_sub.account", "account_sub")
      .where("account_sub.userId = :userId", { userId: user.id })
      .groupBy("ah_sub.account.id")
      .addGroupBy(`DATE(ah_sub.time)`);

    const mainQuery = repository
      .createQueryBuilder("account_history")
      .innerJoinAndSelect("account_history.account", "account")
      .innerJoin("(" + subQuery.getQuery() + ")", "latest_entries", "latest_entries.accountId = account.id AND latest_entries.maxTime = account_history.time")
      .setParameters(subQuery.getParameters())
      .orderBy("account_history.time", "DESC");

    if (opts?.where) mainQuery.andWhere(opts.where);
    return await mainQuery.getMany();
  }
}
