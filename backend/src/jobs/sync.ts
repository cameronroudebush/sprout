import { Configuration } from "@backend/config/core";
import { Logger } from "@backend/logger";
import { Account } from "@backend/model/account";
import { AccountHistory } from "@backend/model/account.history";
import { Holding } from "@backend/model/holding";
import { HoldingHistory } from "@backend/model/holding.history";
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

          // Sync holdings if investment type
          if (accountInDB.type === "investment" && data.holdings.length !== 0) await this.updateHoldingData(accountInDB, data.holdings);
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

  /**
   * Updates holding data for the given account and holding information set.
   */
  private async updateHoldingData(accountInDb: Account, holdings: Holding[]) {
    for (const holding of holdings) {
      holding.account = accountInDb;
      let holdingInDB = (await Holding.find({ where: { symbol: holding.symbol, account: { id: accountInDb.id } } }))[0];
      // If we aren't tracking this holding yet, start tracking it
      if (holdingInDB == null) holdingInDB = await Holding.fromPlain(holding).insert();
      else {
        // Set old holding history
        await HoldingHistory.fromPlain({
          holding: holdingInDB,
          costBasis: holdingInDB.costBasis,
          marketValue: holdingInDB.marketValue,
          purchasePrice: holdingInDB.purchasePrice,
          shares: holdingInDB.shares,
          time: subDays(new Date(), 1),
        }).insert();

        // Update current holding values
        holdingInDB.costBasis = holding.costBasis;
        holdingInDB.marketValue = holding.marketValue;
        holdingInDB.purchasePrice = holding.purchasePrice;
        holdingInDB.shares = holding.shares;
        await holdingInDB.update();
      }
    }
  }
}
