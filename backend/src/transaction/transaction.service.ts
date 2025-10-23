import { Account } from "@backend/account/model/account.model";
import { Configuration } from "@backend/config/core";
import { BillingPeriod, TransactionSubscription } from "@backend/transaction/model/api/transaction.subscription.dto";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";

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
   * @param deviationTolerance The tolerance we allow in-case subscriptions go up in cost.
   * @param requiredCount How many transactions are required to be a recurring.
   * @returns An array of potential subscriptions with their details.
   */
  async findSubscriptions(user: User, deviationTolerance = 0.1, requiredCount = Configuration.transaction.subscriptionCount) {
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
            const transaction = await Transaction.findOne({ where: { description: row.normalizedDescription, account: { id: row.accountId } } });
            if (account)
              return new TransactionSubscription(
                row.normalizedDescription,
                Math.abs(row.averageAmount),
                parseInt(row.count),
                period,
                startDate,
                account,
                transaction!,
              );
          }
          return null;
        }),
      )
    ).filter(Boolean); // Filter out any null values
    return subscriptions as TransactionSubscription[];
  }
}
