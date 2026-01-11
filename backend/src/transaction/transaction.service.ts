import { Account } from "@backend/account/model/account.model";
import { AccountType } from "@backend/account/model/account.type";
import { Configuration } from "@backend/config/core";
import { BillingPeriod, TransactionSubscription } from "@backend/transaction/model/api/transaction.subscription.dto";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";
import { subMonths } from "date-fns";

/**
 * This service provides injectable capabilities for handling data involving Transactions.
 */
@Injectable()
export class TransactionService {
  /**
   * Finds subscriptions by identifying recurring transactions for a user.
   * This method performs an initial data aggregation in the database and
   * then analyzes the results in application code to determine the period,
   * amount with tolerance, and billing day.
   *
   * @param user The user to find subscriptions for.
   * @param requiredCount How many transactions are required to recurring to be considered a sub.
   * @returns An array of potential subscriptions with their details.
   */
  async findSubscriptions(user: User, requiredCount = Configuration.transaction.subscriptionCount) {
    const range = subMonths(new Date(), 6);

    // Get our data from the db
    const potentialSubs = (await Transaction.getRepository()
      .createQueryBuilder("transaction")
      .select("transaction.description", "description")
      .addSelect("transaction.amount", "amount")
      .addSelect("transaction.accountId", "accountId")
      // Aggregates
      .addSelect("COUNT(*)", "count")
      .addSelect("MIN(transaction.posted)", "startDate")
      .addSelect("MAX(transaction.id)", "latestTransactionId")
      .addSelect("(julianday(MAX(transaction.posted)) - julianday(MIN(transaction.posted))) / (COUNT(*) - 1)", "avgIntervalDays")
      // Joins & Filters
      .innerJoin("transaction.account", "account")
      .where("account.userId = :userId", { userId: user.id })
      .andWhere("transaction.posted >= :range", { range })
      .andWhere("transaction.amount < 0") // Expenses only
      // Grouping
      .groupBy("transaction.accountId")
      // .addGroupBy("transaction.description")
      .addGroupBy("transaction.amount")
      // Frequency Filter
      .having("count >= :requiredCount", { requiredCount })
      // Consistency Filter: Must appear in at least N distinct months to be a sub
      .andHaving("COUNT(DISTINCT strftime('%Y-%m', transaction.posted)) >= :requiredCount", { requiredCount })
      // Filter out if 'Days Since Last Transaction' > 'Avg Interval' as this sub may be cancelled
      .andHaving("(julianday('now') - julianday(MAX(transaction.posted))) <= (avgIntervalDays + 10)")
      .getRawMany()) as (TransactionSubscription & { avgIntervalDays: number; latestTransactionId: string; accountId: string })[];

    // Convert subs to the type
    const typedPotentialSubs = await Promise.all(
      potentialSubs.map(async (p) => {
        return TransactionSubscription.fromPlain({
          ...p,
          startDate: new Date(p.startDate),
          period: TransactionSubscription.classifyPeriod(p.avgIntervalDays),
          transaction: await Transaction.findOne({ where: { id: p.latestTransactionId } }),
          account: await Account.findOne({ where: { id: p.accountId } }),
        });
      }),
    );

    // Cleanup to see what's valid
    const subs = typedPotentialSubs.filter((sub) => {
      if (sub.period === BillingPeriod.UNKNOWN) return false;
      if (sub.account.type === AccountType.investment) return false; // Don't consider the stock purchases
      return true;
    });

    return subs;
  }
}
