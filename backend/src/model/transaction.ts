import { Configuration } from "@backend/config/core";
import { DatabaseDecorators } from "@backend/database/decorators";
import { Account } from "@backend/model/account";
import { BillingPeriod, TransactionSubscription } from "@backend/model/api/transaction.subscriptions";
import { Category } from "@backend/model/category";
import { DatabaseBase } from "@backend/model/database.base";
import { User } from "@backend/model/user";
import { ManyToOne } from "typeorm";

@DatabaseDecorators.entity()
export class Transaction extends DatabaseBase {
  /** In the currency of the account */
  @DatabaseDecorators.numericColumn({ nullable: false })
  amount: number;

  @DatabaseDecorators.column({ nullable: false })
  description: string;
  @DatabaseDecorators.column()
  pending: boolean;

  /** The category this transaction belongs to. A null category signifies an unknown category. */
  @ManyToOne(() => Category, (a) => a.id, { nullable: true, eager: true, onDelete: "SET NULL" })
  category?: Category;

  /** The date this transaction posted */
  @DatabaseDecorators.column({ nullable: false })
  posted: Date;

  /** The account this transaction belongs to */
  @ManyToOne(() => Account, (a) => a.id, { eager: true, onDelete: "CASCADE" })
  account: Account;

  /** Any extra data that we want to store as JSON */
  @DatabaseDecorators.jsonColumn({ nullable: true })
  extra?: object;

  constructor(amount: number, posted: Date, description: string, category: Category | undefined, pending: boolean, account: Account) {
    super();
    this.amount = amount;
    this.posted = posted;
    this.description = description;
    this.category = category;
    this.pending = pending;
    this.account = account;
  }

  /**
   * Finds subscriptions by identifying recurring transactions for a user.
   * This method performs an initial data aggregation in the database and
   * then analyzes the results in application code to determine the period,
   * amount with tolerance, and billing day.
   *
   * @param user The user to find subscriptions for.
   * @param deviationTolerance The tolerance we allow in-case subscriptions go up in cost.
   * @param requiredCount How many transactions are required to be a recurring.
   * @returns An array of potential subscriptions with their details.
   */
  static async findSubscriptions(user: User, deviationTolerance = 0.1, requiredCount = Configuration.transaction.subscriptionCount) {
    const repository = Transaction.getRepository();
    const oneYearAgo = new Date();
    oneYearAgo.setFullYear(oneYearAgo.getFullYear() - 1);

    const potentialSubscriptions = await repository
      .createQueryBuilder("transaction")
      .select("transaction.description", "normalizedDescription")
      .addSelect("AVG(transaction.amount)", "averageAmount")
      .addSelect("COUNT(*)", "count")
      .addSelect("GROUP_CONCAT(transaction.posted)", "postedDates")
      .addSelect("GROUP_CONCAT(transaction.amount)", "amounts")
      .addSelect("account.id", "accountId") // Select account ID
      .innerJoin(Account, "account", "transaction.accountId = account.id")
      .where("account.userId = :userId", { userId: user.id })
      .andWhere("transaction.posted >= :oneYearAgo", { oneYearAgo })
      .andWhere("transaction.amount < 0")
      .groupBy("normalizedDescription")
      .having(`COUNT(*) >= ${requiredCount}`)
      .getRawMany();

    const subscriptions = (
      await Promise.all(
        potentialSubscriptions.map(async (row) => {
          const postedDates = row.postedDates
            .split(",")
            .map((d: string) => new Date(d))
            .sort((a: Date, b: Date) => a.getTime() - b.getTime());
          const amounts = row.amounts.split(",").map(Number);
          const startDate = postedDates[0];
          const timeDifferences = [];
          for (let i = 1; i < postedDates.length; i++) timeDifferences.push(postedDates[i].getTime() - postedDates[i - 1].getTime());
          if (timeDifferences.length === 0) return null;
          const averagePeriodMs = timeDifferences.reduce((sum, diff) => sum + diff, 0) / timeDifferences.length;
          const averagePeriodDays = Math.round(averagePeriodMs / (1000 * 60 * 60 * 24));
          const period = TransactionSubscription.classifyPeriod(averagePeriodDays);
          const arePeriodsConsistent = timeDifferences.every((diff) => Math.abs(diff - averagePeriodMs) / averagePeriodMs < deviationTolerance);
          const areAmountsConsistent = amounts.every(
            (amount: number) => Math.abs(amount - row.averageAmount) / Math.abs(row.averageAmount) < deviationTolerance,
          );
          if (arePeriodsConsistent && areAmountsConsistent && period !== BillingPeriod.UNKNOWN) {
            const account = await Account.findOne({ where: { id: row.accountId } });
            if (account)
              return new TransactionSubscription(row.normalizedDescription, Math.abs(row.averageAmount), parseInt(row.count), period, startDate, account);
          }
          return null;
        }),
      )
    ).filter(Boolean); // Filter out any null values
    return subscriptions as TransactionSubscription[];
  }
}
