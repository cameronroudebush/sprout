import { Configuration } from "@backend/config/core";
import { API_CORE } from "@backend/financeAPI/core";
import { Logger } from "@backend/logger";
import { Transaction } from "@backend/model/transaction";
import { User } from "@backend/model/user";
import CronExpressionParser, { CronExpression } from "cron-parser";

/** This class is used to schedule updates to query for data at routine intervals from the Plaid API */
export class Scheduler {
  interval!: CronExpression;

  /** Starts the scheduler to perform updates based on the next result */
  async start() {
    Logger.info(`Initializing scheduler with job of: ${Configuration.updateTime}`);
    // Validate the cronjob
    this.interval = CronExpressionParser.parse(Configuration.updateTime, { tz: process.env["TZ"] ?? "America/New_York" });
    // Perform update now
    await this.update();
  }

  private scheduleNextUpdate() {
    const nextExecutionDate = this.interval.next().toDate();
    Logger.info(`Next update time: ${nextExecutionDate.toISOString()}`);
    const timeUntilNextExecution = nextExecutionDate.getTime() - Date.now();
    setTimeout(async () => {
      await this.start();
    }, timeUntilNextExecution);
  }

  /** Performs an update for our API */
  private async update() {
    Logger.info("Performing background update");
    // Handle each user
    const users = await User.find({});
    await Promise.all(
      users.map(async (user) => {
        try {
          Logger.info(`Updating information for: ${user.username}`);
          // Sync transactions
          const transactions = await API_CORE.App.getTransactions(user);
          // Insert updated data
          await Transaction.insertMany<Transaction>(transactions);
          Logger.success(`Information updated successfully for: ${user.username}`);
        } catch (e) {
          Logger.error(e as Error);
        }
      }),
    );

    // Schedule next update
    this.scheduleNextUpdate();
  }
}
