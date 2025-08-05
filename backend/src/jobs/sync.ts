import { Configuration } from "@backend/config/core";
import { Logger } from "@backend/logger";
import { Account } from "@backend/model/account";
import { AccountHistory } from "@backend/model/account.history";
import { Holding } from "@backend/model/holding";
import { Sync } from "@backend/model/schedule";
import { Transaction } from "@backend/model/transaction";
import { User } from "@backend/model/user";
import { ProviderBase } from "@backend/providers/base/core";
import { subDays } from "date-fns";
import { BackgroundJob } from "./base";

/** This class is used to schedule updates to query for data at routine intervals from the available providers. */
export class BackgroundSync extends BackgroundJob<Sync> {
  constructor(public provider: ProviderBase) {
    super("sync", Configuration.providers.updateTime);
  }

  override async start() {
    // Check if we've ran a job yet today.
    const lastSchedule = (await Sync.find({ skip: 0, take: 1, order: { time: "DESC" } }))[0];
    const hasNotRanSyncToday = lastSchedule == null || lastSchedule.time.toDateString() !== new Date().toDateString();
    return super.start(hasNotRanSyncToday);
  }

  protected async update() {
    Logger.info("Performing background update");
    const schedule = await Sync.fromPlain({ time: new Date(), status: "in-progress" }).insert();
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
          Logger.info(`Updating account from provider: ${data.account.name}`);
          let accountInDB: Account;
          try {
            accountInDB = (await Account.findOne({ where: { id: data.account.id } }))!;
            if (accountInDB == null) throw new Error("Missing account");
          } catch (e) {
            // Ignore missing accounts
            continue;
          }

          // Set old account history
          await AccountHistory.fromPlain({
            account: accountInDB,
            balance: accountInDB.balance,
            availableBalance: accountInDB.availableBalance,
            time: subDays(new Date(), 1),
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
          data.transactions.map((x) => (x.account = accountInDB));
          await Transaction.insertMany<Transaction>(data.transactions);
          // Sync holdings if investment
          if (accountInDB.type === "investment" && data.holdings.length !== 0)
            for (const holding of data.holdings) {
              holding.account = accountInDB;
              let holdingInDB = (await Holding.find({ where: { symbol: holding.symbol, account: { id: accountInDB.id } } }))[0];
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
    return schedule;
  }
}
