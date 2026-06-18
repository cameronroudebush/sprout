import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountType } from "@backend/account/model/account.type";
import { Configuration } from "@backend/config/core";
import { HoldingHistory } from "@backend/holding/model/holding.history.model";
import { Holding } from "@backend/holding/model/holding.model";
import { Sync } from "@backend/jobs/model/sync.model";
import { ProviderBase } from "@backend/providers/base/core";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { User } from "@backend/user/model/user.model";
import { Injectable, Logger } from "@nestjs/common";
import { subDays } from "date-fns";
import { merge } from "lodash";
import { In } from "typeorm";

/** Generic sync service to sync provider account info for users. Dynamically used across background jobs and manual calls. */
@Injectable()
export class ProviderSyncService {
  private readonly logger = new Logger("provider:sync:service");

  constructor(private readonly transactionRuleService: TransactionRuleService) {}

  /**
   * Given a user and a provider, initiates a sync for them by grabbing their accounts and updating them in the database
   *
   * @param notify If we should send a notification that the user has new data. This will be batched and sent via the {@link SyncNotificationJob}.
   */
  async syncForProvider(user: User, provider: ProviderBase, notify = true) {
    if (!(await provider.isAvailable(user))) {
      this.logger.debug(`Provider is not enabled for ${user.username}, skipping update.`);
      return;
    }

    this.logger.log(`Processing sync for user: ${user.username} for provider: ${provider.config.dbType}`);
    const sync = await Sync.fromPlain({
      time: new Date(),
      status: "in-progress",
      provider: provider.config.dbType,
      notified: !notify, // Invert notify case. If we don't want notified, this makes us think we already told the user and vice versa.
    }).insert();
    sync.user = user;
    try {
      const result = await this.syncUserAccounts(user, provider);
      if (result.institutionErrors.size > 0) {
        const names = Array.from(result.institutionErrors);
        sync.status = "failed";
        sync.failureReason = `Connection lost with ${names.join(", ")}`;
      } else {
        sync.status = "complete";
      }
      await sync.update();
    } catch (e) {
      sync.status = "failed";
      sync.failureReason = (e as Error).message;
      await sync.update();
      this.logger.error(`An error occurred during a sync: ${e}`);
    }
    return sync;
  }

  /** Connects to the provider, updates accounts, transactions, and holdings */
  private async syncUserAccounts(user: User, provider: ProviderBase) {
    const institutionErrors = new Set<string>();

    // Fast-fail if the user has no accounts linked yet
    const userAccountsCount = await Account.count({ where: { user: { id: user.id } } });
    if (userAccountsCount === 0) return { institutionErrors, userHadSuccessfulUpdate: false };

    // Grab the up to date transaction/account info from the provider
    const accounts = await provider.get(user, false);
    if (accounts.length === 0) this.logger.debug(`No accounts available for ${user.username} on provider ${provider.config.dbType}`);

    return this.handleAccountsUpdate(accounts, user);
  }

  /** This function handles the actual account updates for a user/account combo by writing the data to the DB as necessary. */
  private async handleAccountsUpdate(accounts: Awaited<ReturnType<ProviderBase["get"]>>, user: User) {
    const institutionErrors = new Set<string>();
    let userHadSuccessfulUpdate = false;

    for (const data of accounts) {
      try {
        const accountInDB = await Account.findOne({ where: { id: data.account.id, user: { id: user.id } }, relations: { institution: true } });
        // Skip missing accounts. We will not insert them, that's the link job from the specific provider.
        if (!accountInDB) continue;

        // Save Account Balance History
        await AccountHistory.fromPlain({
          account: accountInDB,
          balance: accountInDB.balance,
          availableBalance: accountInDB.availableBalance,
          time: subDays(new Date(), 1),
        }).insert();

        // Update Current Account Balances
        accountInDB.balance = data.account.balance;
        accountInDB.availableBalance = data.account.availableBalance;
        await accountInDB.update();

        // Update Institution Error State
        const institution = accountInDB.institution;
        institution.hasError = data.account.institution.hasError;
        institution.url = data.account.institution.url;
        await institution.update();

        if (data.account.institution.hasError) institutionErrors.add(data.account.institution.name);

        // Sync Transactions
        if (data.transactions && data.transactions.length > 0) await this.updateTransactionDataBulk(accountInDB, data.transactions);
        if (data.removedTransactionIds && data.removedTransactionIds.length > 0) await Transaction.delete({ id: In(data.removedTransactionIds) });
        // Sync Holdings
        if (data.holdings && accountInDB.type === AccountType.investment) await this.updateHoldingData(accountInDB, data.holdings);

        userHadSuccessfulUpdate = true;
      } catch (e) {
        this.logger.error(`Account error for ${user.username}: ${(e as Error).message}`);
      }
    }

    // Apply rules to all new transactions if at least one account worked
    if (userHadSuccessfulUpdate) await this.transactionRuleService.applyRulesToTransactions(user, undefined, true);

    return { institutionErrors, userHadSuccessfulUpdate };
  }

  /** Secure, high-performance bulk upsert for transactions */
  private async updateTransactionDataBulk(accountInDb: Account, transactions: Transaction[]) {
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

  /** Syncs holdings and records holding history */
  private async updateHoldingData(accountInDb: Account, holdings: Holding[]) {
    const holdingsInDb = await Holding.getForAccount(accountInDb);

    for (const holding of holdings) {
      holding.account = accountInDb;
      let holdingInDBIndex = holdingsInDb.findIndex((x) => x.symbol === holding.symbol);
      let holdingInDB = holdingsInDb[holdingInDBIndex];

      if (holdingInDB == null) {
        await Holding.fromPlain(holding).insert(false);
      } else {
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

    // Process removed/missing holdings
    for (const remainingHolding of holdingsInDb) {
      if (Configuration.holding.cleanupRemovedHoldings) {
        this.logger.warn(`Removing holding ${remainingHolding.id} because it was not found.`);
        await remainingHolding.remove();
      } else {
        remainingHolding.marketValue = 0;
        remainingHolding.costBasis = 0;
        remainingHolding.purchasePrice = 0;
        remainingHolding.shares = 0;
        await remainingHolding.update();
      }
    }
  }
}
