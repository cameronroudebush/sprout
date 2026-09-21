import { Category } from "@backend/category/model/category.model";
import { DatabaseService } from "@backend/database/database.service";
import { TransactionSubscription } from "@backend/transaction/model/api/transaction.subscription.dto";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";
import { addDays, differenceInDays } from "date-fns";
import * as fs from "fs/promises";
import path from "path";

/**
 * This service provides injectable capabilities for handling data involving Transactions.
 */
@Injectable()
export class TransactionService {
  /** SQL file that contains the complex subscription lookup query */
  private static readonly SUBSCRIPTION_FILE = path.join(__dirname, "transaction", "sql", "subscription.sql");

  constructor(private readonly databaseService: DatabaseService) {}

  /**
   * Finds subscriptions by identifying recurring transactions for a user.
   * This updated method pulls all expense transactions from credit and depository accounts,
   * clusters them using a normalized description to account for variable-amount bills
   * (like utilities), and evaluates the interval variance to confirm a subscription.
   *
   * @param user The user to find subscriptions for.
   * @param overdueDays How many days overdue a subscription should be considered no longer valid.
   * @param transactionCount How many transactions count as a subscription. So we must see it at-least N times to count.
   * @param increasedVariance How much fluctuation in bill amounts for {@link Category.increasedSubVariance}
   * @param variance How much fluctuation in bill amounts to allow.
   * @returns An array of potential subscriptions with their details.
   */
  async findSubscriptions(user: User, overdueDays = 40, transactionCount = 2, increasedVariance = 1.2, variance = 0.2) {
    const subscriptions: TransactionSubscription[] = [];
    const today = new Date();
    const sqlQuery = await fs.readFile(TransactionService.SUBSCRIPTION_FILE, "utf-8");
    const rawResults = await this.databaseService.source.query(sqlQuery, [user.id, transactionCount, increasedVariance, variance]);

    // Process results and filter inactive subscriptions
    for (const row of rawResults) {
      const lastPostedDate = new Date(row.last_posted);
      const avgDaysBetween = row.avg_days_between;

      // Calculate when the NEXT bill should have hit
      const expectedNextBillingDate = addDays(lastPostedDate, avgDaysBetween);
      // Calculate how many days past the expected date we currently are
      const daysOverdue = differenceInDays(today, expectedNextBillingDate);

      // If the bill is more than N days late, it is considered inactive/missed.
      if (daysOverdue > overdueDays) continue;

      // Map valid subscriptions to the DTO
      const period = TransactionSubscription.classifyPeriod(avgDaysBetween);
      const transaction = (await Transaction.findOne({ where: { id: row.transactionId } }))!;
      const subscription = new TransactionSubscription(
        row.latest_description,
        row.avg_amount,
        row.transaction_count,
        period,
        new Date(row.first_posted),
        transaction.account,
        transaction,
      );
      subscriptions.push(subscription);
    }

    return subscriptions;
  }
}
