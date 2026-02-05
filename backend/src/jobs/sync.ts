import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountType } from "@backend/account/model/account.type";
import { Configuration } from "@backend/config/core";
import { TimeZone } from "@backend/config/model/tz";
import { Utility } from "@backend/core/model/utility/utility";
import { HoldingHistory } from "@backend/holding/model/holding.history.model";
import { Holding } from "@backend/holding/model/holding.model";
import { Sync } from "@backend/jobs/model/sync.model";
import { Notification } from "@backend/notification/model/notification.model";
import { NotificationType } from "@backend/notification/model/notification.type";
import { NotificationService } from "@backend/notification/notification.service";
import { ProviderBase } from "@backend/providers/base/core";
import { ProviderService } from "@backend/providers/provider.service";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { User } from "@backend/user/model/user.model";
import { subDays } from "date-fns";
import { groupBy, merge } from "lodash";
import { BackgroundJob } from "./base";

/** This class is used to schedule updates to query for data at routine intervals from the available providers. */
export class ProviderSyncJob extends BackgroundJob<Sync> {
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
    const schedule = await Sync.fromPlain({ time: new Date(), status: "in-progress" }).insert();
    schedule.user = user;
    // A map of result notifications per user.
    const totalResults: Notification[] = [];
    try {
      for (const provider of providers) totalResults.push(...(await this.updateProvider(provider, user)));
    } catch (e) {
      // Worst case, major issues exist and we need to log it within the sync status
      const msg = (e as Error).message;
      schedule.failureReason = msg;
      schedule.status = "failed";
      await schedule.update();
      throw e;
    }

    // Finalize the schedule status
    schedule.status = "complete";
    await schedule.update();

    // Inform the user of each most important notifications
    const notifications = groupBy(totalResults, "user.id");
    for (const [_userId, items] of Object.entries(notifications)) {
      // Check for immediate problems (Errors or Warnings)
      const problems = items.filter((n) => n.type === NotificationType.error || n.type === NotificationType.warning);

      if (problems.length > 0)
        // If problems exist, notify the user of ALL of them
        for (const problem of problems) await this.notificationService.notifyUser(problem.user, problem.message, problem.title, problem.type);
      else {
        // If no problems, find the first success (if it exists)
        const success = items.find((n) => n.type === NotificationType.success);
        if (success) await this.notificationService.notifyUser(success.user, success.message, success.title, success.type);
      }
    }

    return schedule;
  }

  /**
   * Starts an update for the given provider.
   *
   * @param specificUser If given, will only process this user
   * @returns An array of the results of our update
   */
  private async updateProvider(provider: ProviderBase, specificUser?: User) {
    this.logger.log(`Syncing ${provider.config.name}`);
    // Handle each user, or only the given user
    const users = specificUser ? [specificUser] : await User.find({});
    // Initialize the return array
    const results: Notification[] = [];
    // Handle each user's accounts
    for (const user of users) {
      this.logger.log(`Updating information for: ${user.username}`);
      // Sync transactions and account balances. Only do it for existing accounts.
      const userAccounts = await Account.getForUser(user);
      // If we don't have any user accounts, don't bother querying because we'll have nothing to update
      if (userAccounts.length === 0) continue;

      let accounts;
      try {
        accounts = await provider.get(user, false);
      } catch (err) {
        this.logger.error(`Failed to fetch provider data for ${user.username}`);
        results.push(new Notification(user, "Provider Fetch Failed", `Failed to fetch the ${provider.config.name} information.`, NotificationType.error));
        continue;
      }

      let userHadSuccessfulUpdate = false;
      let institutionNamesToUpdate: string[] = [];

      for (const data of accounts) {
        try {
          const accountInDB = await Account.findOne({ where: { id: data.account.id } });
          if (!accountInDB) {
            this.logger.warn(`The account with the following name isn't registered: ${data.account.name}`);
            continue;
          } else this.logger.log(`Updating account from provider: ${data.account.name}`);

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
          if (institution.hasError) institutionNamesToUpdate.push(institution.name);

          // Sync transactions
          if (data.transactions.length !== 0) await this.updateTransactionData(accountInDB, data.transactions);

          // Sync holdings if investment type
          if (accountInDB.type === AccountType.investment) await this.updateHoldingData(accountInDB, data.holdings);

          // If we reached this point, this specific account sync was valid
          userHadSuccessfulUpdate = true;
        } catch (e) {
          this.logger.error(`Failed to update account ${data.account.name} for ${user.username}: ${(e as Error).message}`);
          continue;
        }
      }

      // Post-Loop Notification & Result Logic
      if (institutionNamesToUpdate.length > 0) {
        // Handle Institution Errors (User Action Required)
        results.push(
          new Notification(
            user,
            "Connection Update Required",
            `Connection lost with ${institutionNamesToUpdate.length > 1 ? "multiple institutions" : institutionNamesToUpdate[0]}. Please update your login credentials.`,
            NotificationType.error,
          ),
        );
      } else if (userHadSuccessfulUpdate) {
        // Successful Update
        const message = this.randomSuccessMessage;
        results.push(new Notification(user, message.title, message.body, NotificationType.success));
        await this.transactionRuleService.applyRulesToTransactions(user, undefined, true);
        this.logger.log(`Information updated successfully for: ${user.username}, provider: ${provider.config.name}`);
      } else {
        // Generic Failure (No updates succeeded, but no specific institution error)
        if (accounts.length > 0)
          results.push(
            new Notification(
              user,
              "Sync Issue",
              `We couldn't update your accounts for ${provider.config.name}. Please check your connection.`,
              NotificationType.error,
            ),
          );
        else
          results.push(
            new Notification(user, "Unknown Sync Issue", `Failed to update your accounts. Please check the logs for more information.`, NotificationType.error),
          );
      }
    }

    return results;
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

  /** Returns a random success message for the user */
  get randomSuccessMessage() {
    return Utility.randomFromArray([
      { title: "Sync Success", body: `Your financial overview is now up to date for ${TimeZone.formatDate(new Date(), "PPP")}.` },
      { title: "Data Refreshed", body: "We've pulled in your latest transactions. Take a look at your updated balances!" },
      { title: "You're All Caught Up", body: "Your accounts have been synced. Your dashboard is now current." },
      { title: "Financial Pulse Update", body: "New data is ready! See how your finances look today." },
    ]);
  }
}
