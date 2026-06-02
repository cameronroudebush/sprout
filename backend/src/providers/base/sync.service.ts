import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountType } from "@backend/account/model/account.type";
import { Configuration } from "@backend/config/core";
import { Utility } from "@backend/core/model/utility/utility";
import { HoldingHistory } from "@backend/holding/model/holding.history.model";
import { Holding } from "@backend/holding/model/holding.model";
import { Sync } from "@backend/jobs/model/sync.model";
import { Notification } from "@backend/notification/model/notification.model";
import { NotificationType } from "@backend/notification/model/notification.type";
import { NotificationService } from "@backend/notification/notification.service";
import { ProviderBase } from "@backend/providers/base/core";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { User } from "@backend/user/model/user.model";
import { Injectable, Logger } from "@nestjs/common";
import { subDays, subMinutes } from "date-fns";
import { In, MoreThan } from "typeorm";

/** Generic sync service to sync provider account info for users. Dynamically used across background jobs and manual calls. */
@Injectable()
export class ProviderSyncService {
  private readonly logger = new Logger("provider:sync:service");

  constructor(
    private readonly transactionRuleService: TransactionRuleService,
    private readonly notificationService: NotificationService,
    private readonly sseService: SSEService,
  ) {}

  /**
   * Given a user and a provider, initiates a sync for them by grabbing their accounts and updating them in the database
   *
   * @param notify If we should send a notification that the user has new data.
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
      if (notify) await this.handleNotifications(user, sync.status === "complete", sync.failureReason);
    } catch (e) {
      sync.status = "failed";
      sync.failureReason = (e as Error).message;
      await sync.update();
      if (notify) await this.handleNotifications(user, false, sync.failureReason);
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
        const accountInDB = await Account.findOne({ where: { id: data.account.id, user: { id: user.id } }, relations: ["institution"] });
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

  /** Determines which notifications to send based on the sync outcome */
  private async handleNotifications(user: User, isSuccess: boolean, failureReason?: string) {
    if (isSuccess) {
      // Real-time UI refresh
      this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);
      // Push Notification (With Spam Check)
      const recentNotification = await Notification.findOne({
        where: {
          user: { id: user.id },
          type: NotificationType.success,
          createdAt: MoreThan(subMinutes(new Date(), 5)),
        },
      });

      if (!recentNotification) {
        const message = this.getSuccessMessage();
        await this.notificationService.notifyUser(user, message.body, message.title, NotificationType.success);
      }
    } else {
      // Send error alert, bypass spam check so the user knows about it.
      await this.notificationService.notifyUser(
        user,
        failureReason || "An unknown error occurred while syncing.",
        "Connection Update Required",
        NotificationType.error,
      );
    }
  }

  /** Secure, high-performance bulk upsert for transactions */
  private async updateTransactionDataBulk(accountInDb: Account, transactions: Transaction[]) {
    const transactionEntities = transactions.map((t) => ({
      ...t,
      account: accountInDb,
      description: t.description || accountInDb.name,
      categoryId: t.category?.id,
    }));

    await Transaction.upsertMany(transactionEntities);
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

  /** Returns a random message for a success when this provider is updated. */
  private getSuccessMessage() {
    return Utility.randomFromArray([
      { title: `Accounts Synced`, body: `Your accounts are up to date.` },
      { title: "You're All Caught Up", body: "We've finished syncing your accounts." },
    ]);
  }
}
