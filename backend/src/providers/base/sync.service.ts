import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountType } from "@backend/account/model/account.type";
import { Configuration } from "@backend/config/core";
import { HoldingHistory } from "@backend/holding/model/holding.history.model";
import { Holding } from "@backend/holding/model/holding.model";
import { Institution } from "@backend/institution/model/institution.model";
import { ProviderBase } from "@backend/providers/base/core";
import { Sync } from "@backend/providers/model/sync.model";
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
   * @param institutionId Optional ID of a specific institution to sync. If provided, skips syncing other institutions for this provider.
   */
  async syncForProvider<T extends ProviderBase>(user: User, provider: T, notify = true, institutionId?: string) {
    if (!(await provider.isAvailable(user))) {
      this.logger.debug(`Provider is not enabled for ${user.username}, skipping update.`);
      return;
    }
    this.logger.log(
      `Processing sync for user: ${user.username} for provider: ${provider.config.dbType}${institutionId ? ` [Institution: ${institutionId}]` : ""}`,
    );
    const sync = await Sync.fromPlain({
      time: new Date(),
      status: "in-progress",
      provider: provider.config.dbType,
      notified: !notify, // Invert notify case. If we don't want notified, this makes us think we already told the user and vice versa.
    }).insert();
    sync.user = user;
    try {
      const result = await this.syncUserAccounts(user, provider, institutionId);
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

  /** Flags the given institution with any errors and warnings as seen fit. */
  async flagInstitution(institution: Institution, hasError: boolean) {
    institution.hasError = hasError;
    await institution.update();
  }

  /** Connects to the provider, updates accounts, transactions, and holdings */
  private async syncUserAccounts(user: User, provider: ProviderBase, institutionId?: string) {
    const institutionErrors = new Set<string>();

    // Fast-fail if the user has no accounts linked yet. They then wouldn't have used any providers.
    const userAccountsCount = await Account.count({ where: { user: { id: user.id } } });
    if (userAccountsCount === 0) return { institutionErrors, userHadSuccessfulUpdate: false };

    const accounts = await provider.get(user, false, institutionId);
    if (accounts.length === 0) return { institutionErrors, userHadSuccessfulUpdate: false };

    // Pass the provider instance into handleAccountsUpdate
    return this.handleAccountsUpdate(provider, accounts, user, institutionId);
  }

  /** This function handles the actual account updates for a user/account combo by writing the data to the DB as necessary. */
  private async handleAccountsUpdate(provider: ProviderBase, accounts: Awaited<ReturnType<ProviderBase["get"]>>, user: User, institutionId?: string) {
    const institutionErrors = new Set<string>();
    let userHadSuccessfulUpdate = false;
    let syncMetadataToCommit: any = null;

    for (const data of accounts) {
      try {
        let accountInDB = await Account.findOne({ where: { id: data.account.id, user: { id: user.id } }, relations: { institution: true } });
        // Determine if we should insert the missing account
        if (!accountInDB) {
          // If the provider returned a providerAccountId, it means this is a newly discovered account that we can auto-link
          if (data.providerAccountId) {
            accountInDB = await data.account.insert();
            await AccountHistory.insertForNewAccount(accountInDB);
            await provider.createAccountAsset(accountInDB, data.providerAccountId);

            // Reload relation
            accountInDB = await Account.findOne({
              where: { id: accountInDB.id, user: { id: user.id } },
              relations: { institution: true },
            });
          }

          // If it still doesn't exist (e.g., missing providerAccountId or manual-only source), skip it
          if (!accountInDB) continue;
        }
        // If we're filtering by an institutionId, and this account isn't that institution, skip it
        if (institutionId && accountInDB.institution.id !== institutionId) continue;

        let institution: Institution | null = accountInDB.institution;
        const incomingInstitution = data.account.institution;
        // Resolve the institution if it isn't attached to the account yet
        if (!institution) {
          institution = await Institution.findOne({ where: { user: { id: user.id }, name: incomingInstitution.name } });

          if (!institution) {
            // Brand new institution: configure and insert it
            institution = incomingInstitution;
            incomingInstitution.user = user;
            await institution.insert();
          }
          // Ensure it gets attached to the account for any future DB updates
          accountInDB.institution = institution;
        }

        // Sync the error state if it differs
        if (institution.hasError !== incomingInstitution.hasError) await this.flagInstitution(institution, incomingInstitution.hasError);

        // Save Account Balance History
        await AccountHistory.insertForAccount(accountInDB);

        // Update Current Account Balances
        accountInDB.balance = data.account.balance;
        accountInDB.availableBalance = data.account.availableBalance;
        await accountInDB.update();

        if (data.account.institution.hasError) institutionErrors.add(data.account.institution.name);

        // Sync Transactions
        if (data.transactions && data.transactions.length > 0) await this.updateTransactionDataBulk(accountInDB, data.transactions);
        if (data.removedTransactionIds && data.removedTransactionIds.length > 0) await Transaction.delete({ id: In(data.removedTransactionIds) });
        // Sync Holdings
        if (data.holdings && accountInDB.type === AccountType.investment) await this.updateHoldingData(accountInDB, data.holdings);

        userHadSuccessfulUpdate = true;
        if (data.syncMetadata) syncMetadataToCommit = data.syncMetadata;
      } catch (e) {
        this.logger.error(`Account error for ${user.username}: ${(e as Error).message}`);
      }
    }

    // Commit metadata ONLY AFTER DB writes were successfully transacted
    if (userHadSuccessfulUpdate && syncMetadataToCommit) await provider.commitSyncMetadata?.(syncMetadataToCommit);
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
