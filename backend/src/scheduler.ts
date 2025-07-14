import { Configuration } from "@backend/config/core";
import { Logger } from "@backend/logger";
import { Account } from "@backend/model/account";
import { AccountHistory } from "@backend/model/account.history";
import { Holding } from "@backend/model/holding";
import { Schedule } from "@backend/model/schedule";
import { Transaction } from "@backend/model/transaction";
import { User } from "@backend/model/user";
import CronExpressionParser, { CronExpression } from "cron-parser";
import { ProviderBase } from "./providers/base/core";

/** This class is used to schedule updates to query for data at routine intervals from the available providers. */
export class Scheduler {
  interval!: CronExpression;

  constructor(public provider: ProviderBase) {}

  /** Starts the scheduler to perform updates based on the next result */
  async start() {
    Logger.info(`Initializing scheduler with job of: ${Configuration.updateTime}`);
    // Validate the cronjob
    this.interval = CronExpressionParser.parse(Configuration.updateTime, { tz: process.env["TZ"] ?? "America/New_York" });
    // Perform update, if one wasn't ran today. Else schedule the next update
    const lastSchedule = (await Schedule.find({ skip: 0, take: 1, order: { time: "DESC" } }))[0];
    if (lastSchedule == null || lastSchedule.time.toDateString() !== new Date().toDateString()) await this.update();
    else this.scheduleNextUpdate();
  }

  private scheduleNextUpdate() {
    const nextExecutionDate = this.interval.next().toDate();
    const timeUntilNextExecution = nextExecutionDate.getTime() - Date.now();
    Logger.info(`Next update time: ${nextExecutionDate.toLocaleString()} (${timeUntilNextExecution}ms)`);
    setTimeout(async () => {
      await this.update();
    }, timeUntilNextExecution);
  }

  /** Performs an update for our API */
  private async update() {
    Logger.info("Performing background update");
    const schedule = await Schedule.fromPlain({ time: new Date(), status: "in-progress" }).insert();
    // Handle each user
    const users = await User.find({});

    try {
      // Handle each users accounts
      for (const user of users) {
        Logger.info(`Updating information for: ${user.username}`);
        // Sync transactions and account balances. Only do it for existing accounts.
        const userAccounts = await Account.getForUser(user);
        // If we don't have any user accounts, don't bother querying because we'll have nothing to update
        if (userAccounts.length === 0) continue;
        const accounts = await this.provider.get(user, false);
        for (const data of accounts) {
          let accountInDB: Account;
          try {
            accountInDB = (await Account.findOne({ where: { id: data.account.id } }))!;
          } catch (e) {
            // Ignore missing accounts
            continue;
          }

          // Set old account history
          await AccountHistory.fromPlain({
            account: accountInDB,
            balance: accountInDB.balance,
            availableBalance: accountInDB.availableBalance,
            time: new Date(),
          }).insert();
          // Update current account
          accountInDB.balance = data.account.balance;
          accountInDB.availableBalance = data.account.availableBalance;
          await accountInDB.update();
          // Update current institution if in database
          const institution = accountInDB.institution;
          institution.hasError = data.account.institution.hasError;
          await institution.update();
          // Sync transactions
          await Transaction.insertMany<Transaction>(data.transactions);
          // Sync holdings if investment
          if (accountInDB.type === "investment" && data.holdings.length !== 0)
            for (const holding of data.holdings) {
              let holdingInDB = (await Holding.find({ where: { symbol: holding.symbol } }))[0];
              // If we aren't tracking this holding yet, start tracking it
              if (holdingInDB == null) holdingInDB = await Holding.fromPlain(holding).insert();
              else {
                // Else, update values
                holdingInDB.costBasis = holding.costBasis;
                holdingInDB.marketValue = holding.marketValue;
                holdingInDB.purchasePrice = holding.purchasePrice;
                holdingInDB.shares = holding.shares;
                await holdingInDB.update();
              }
            }
        }
        Logger.success(`Information updated successfully for: ${user.username}`);
      }
      schedule.status = "complete";
      await schedule.update();
    } catch (e) {
      Logger.error(e as Error);
      schedule.failureReason = (e as Error).message;
      schedule.status = "failed";
      await schedule.update();
    }

    // Schedule next update
    this.scheduleNextUpdate();
  }
}
