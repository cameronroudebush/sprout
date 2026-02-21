import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountType } from "@backend/account/model/account.type";
import { Configuration } from "@backend/config/core";
import { TimeZone } from "@backend/config/model/tz";
import { Utility } from "@backend/core/model/utility/utility";
import { HoldingHistory } from "@backend/holding/model/holding.history.model";
import { Holding } from "@backend/holding/model/holding.model";
import { Sync } from "@backend/jobs/model/sync.model";
import { NotificationType } from "@backend/notification/model/notification.type";
import { NotificationService } from "@backend/notification/notification.service";
import { ProviderBase } from "@backend/providers/base/core";
import { ProviderService } from "@backend/providers/provider.service";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { User } from "@backend/user/model/user.model";
import { subDays } from "date-fns";
import { merge } from "lodash";
import { LessThan } from "typeorm";
import { BackgroundJob } from "./base";

/** This class is used to schedule updates to query for data at routine intervals from the available providers. */
export class ProviderSyncJob extends BackgroundJob<Sync | null> {
  constructor(
    private providerService: ProviderService,
    private transactionRuleService: TransactionRuleService,
    private notificationService: NotificationService,
  ) {
    super("account:sync", Configuration.providers.updateTime);
  }

  public override async updateNow(user?: User) {
    return await this.update(user);
  }

  protected async update(user?: User) {
    this.logger.log("Starting sync for all providers." + (user ? ` Only for user: ${user?.username}` : ""));
    const providers = this.providerService.getAll();
    for (const provider of providers) await this.updateProvider(provider, user);
    // Cleanup
    await this.cleanupOldSyncs();
    // If we we're given a single user, find their most recent sync status
    if (user) return await Sync.findOne({ where: { user: { id: user.id } }, order: { time: "DESC" } });
    else return null;
  }

  /**
   * Starts an update for the given provider.
   *
   * @param specificUser If given, will only process this user
   */
  private async updateProvider(provider: ProviderBase, specificUser?: User) {
    this.logger.log(`Syncing ${provider.config.name}`);
    // Handle each user, or only the given user
    const users = specificUser ? [specificUser] : await User.find({});
    // Handle each user's accounts
    for (const user of users) {
      // Create unique sync status
      const sync = await Sync.fromPlain({
        time: new Date(),
        status: "in-progress",
        user: user,
      }).insert();
      try {
        this.logger.log(`Updating ${provider.config.name} for: ${user.username}`);
        // Sync transactions and account balances. Only do it for existing accounts.
        const userAccounts = await Account.getForUser(user);
        // If we don't have any user accounts, don't bother querying because we'll have nothing to update
        if (userAccounts.length === 0) {
          sync.status = "complete";
          await sync.update();
          continue;
        }

        let accounts;
        try {
          accounts = await provider.get(user, false);
        } catch (err) {
          throw new Error(`Provider connection failed: ${(err as Error).message}`);
        }

        let userHadSuccessfulUpdate = false;
        const institutionErrors = new Set<string>();

        for (const data of accounts) {
          try {
            const accountInDB = await Account.findOne({ where: { id: data.account.id, user: { id: user.id } } });
            if (!accountInDB) continue;

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
            institution.url = data.account.institution.url;
            await institution.update();

            // Check if the institution reports an error
            if (data.account.institution.hasError) institutionErrors.add(data.account.institution.name);
            // Sync transactions
            if (data.transactions.length !== 0) await this.updateTransactionData(accountInDB, data.transactions);
            // Sync holdings if investment type
            if (accountInDB.type === AccountType.investment) await this.updateHoldingData(accountInDB, data.holdings);

            // If we reached this point, this specific account sync was valid
            userHadSuccessfulUpdate = true;
          } catch (e) {
            this.logger.error(`Account error: ${(e as Error).message}`);
          }
        }

        // Always apply rules if at least one account updated successfully
        if (userHadSuccessfulUpdate) await this.transactionRuleService.applyRulesToTransactions(user, undefined, true);

        // Finalize status and notify the user as necessary
        if (institutionErrors.size > 0) {
          const names = Array.from(institutionErrors);
          sync.status = "failed";
          sync.failureReason = `Connection lost with ${names.join(", ")}`;
          await this.notificationService.notifyUser(user, sync.failureReason, "Connection Update Required", NotificationType.error);
        } else if (userHadSuccessfulUpdate) {
          sync.status = "complete";
          const msg = this.randomSuccessMessage;
          await this.notificationService.notifyUser(user, msg.body, msg.title, NotificationType.success);
        } else {
          sync.status = "failed";
          sync.failureReason = "No accounts were updated. Check provider logs.";
        }
        // Finalize by updating the sync
        await sync.update();
      } catch (e) {
        // Catch-all for a total user-provider failure
        sync.status = "failed";
        sync.failureReason = (e as Error).message;
        await sync.update();
        this.logger.error(`Sync failed for ${user.username}: ${sync.failureReason}`);
      }
    }
  }

  /** Updates all transaction data for the given account that matches the given transaction */
  private async updateTransactionData(accountInDb: Account, transactions: Transaction[]) {
    for (const transaction of transactions) {
      transaction.account = accountInDb;
      // If the transaction description is empty, fill it with something
      if (transaction.description === "" || !transaction.description) transaction.description = accountInDb.name;
      let transactionInDb = (await Transaction.find({ where: { id: transaction.id, account: { id: accountInDb.id } } }))[0];
      // If we aren't tracking this transaction yet, go ahead and add it
      if (transactionInDb == null) transactionInDb = await Transaction.fromPlain(transaction).insert(false);
      else {
        // Update our related transaction
        transactionInDb.amount = transaction.amount;
        transactionInDb.pending = transaction.pending;
        transactionInDb.posted = transaction.posted;
        transactionInDb.extra = merge(transactionInDb.extra, transaction.extra);
        // If we haven't already set it's category, go ahead and set it
        if (transactionInDb.category == null) transactionInDb.category = transaction.category;
        await transactionInDb.update();
      }
    }
  }

  /**
   * Updates holding data for the given account and holding information set.
   */
  private async updateHoldingData(accountInDb: Account, holdings: Holding[]) {
    const holdingsInDb = await Holding.getForAccount(accountInDb);
    // Process any of the holding info as given by the provider
    for (const holding of holdings) {
      holding.account = accountInDb;
      let holdingInDBIndex = holdingsInDb.findIndex((x) => x.symbol === holding.symbol);
      let holdingInDB = holdingsInDb[holdingInDBIndex];
      // If we aren't tracking this holding yet, start tracking it
      if (holdingInDB == null) holdingInDB = await Holding.fromPlain(holding).insert(false);
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

        // Remove it from the list so we don't process it later
        holdingsInDb.splice(holdingInDBIndex, 1);
      }
    }

    // Any holdings that we're not processed are probably removed (or the provider is having an error) so handle them below
    for (const remainingHolding of holdingsInDb) {
      // WARN: This will remove holdings history completely.
      if (Configuration.holding.cleanupRemovedHoldings) {
        this.logger.warn(`Removing holding with ID ${remainingHolding.id} because it was not found in the provider info.`);
        await remainingHolding.remove();
      } else {
        // Cleanup the holding but keep it just so we still have the history
        remainingHolding.marketValue = 0;
        remainingHolding.costBasis = 0;
        remainingHolding.purchasePrice = 0;
        remainingHolding.shares = 0;
        await remainingHolding.update();
      }
    }
  }

  /** Removes sync history older than N days to maintain database performance. */
  private async cleanupOldSyncs(days = 60) {
    try {
      const thirtyDaysAgo = subDays(new Date(), days);
      const result = await Sync.delete({
        time: LessThan(thirtyDaysAgo),
      });
      const cleaned = result.affected;
      this.logger.log(`Removed ${cleaned} old sync record${cleaned !== 1 ? "s" : ""}.`);
    } catch (e) {
      this.logger.error(`Failed to cleanup old sync records: ${(e as Error).message}`);
    }
  }

  /** Returns a random success message for the user */
  private get randomSuccessMessage() {
    return Utility.randomFromArray([
      { title: "Sync Success", body: `Your financial overview is now up to date for ${TimeZone.formatDate(new Date(), "PPP")}.` },
      { title: "Data Refreshed", body: "We've pulled in your latest transactions. Take a look at your updated balances!" },
      { title: "You're All Caught Up", body: "Your accounts have been synced. Your dashboard is now current." },
      { title: "Financial Pulse Update", body: "New data is ready! See how your finances look today." },
    ]);
  }
}
