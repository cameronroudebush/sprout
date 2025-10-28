import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountType } from "@backend/account/model/account.type";
import { Configuration } from "@backend/config/core";
import { HoldingHistory } from "@backend/holding/model/holding.history.model";
import { Holding } from "@backend/holding/model/holding.model";
import { Sync } from "@backend/jobs/model/sync.model";
import { ProviderBase } from "@backend/providers/base/core";
import { ProviderService } from "@backend/providers/provider.service";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { User } from "@backend/user/model/user.model";
import { subDays } from "date-fns";
import { merge } from "lodash";
import { BackgroundJob } from "./base";

/** This class is used to schedule updates to query for data at routine intervals from the available providers. */
export class ProviderSyncJob extends BackgroundJob<Sync> {
  constructor(
    private providerService: ProviderService,
    private transactionRuleService: TransactionRuleService,
  ) {
    super("provider-sync", Configuration.providers.updateTime);
  }

  public override async updateNow(user?: User) {
    return await this.update(user);
  }

  protected async update(user?: User) {
    this.logger.log("Starting sync for all providers.");
    const providers = this.providerService.getAll();
    const schedule = await Sync.fromPlain({ time: new Date(), status: "in-progress" }).insert();
    schedule.user = user;
    try {
      for (const provider of providers) await this.updateProvider(provider, user);
    } catch (e) {
      schedule.failureReason = (e as Error).message;
      schedule.status = "failed";
      await schedule.update();
      // Don't fail graceful, let the jobs base handle this
      throw e;
    }
    // Make sure to track that the update is complete with no errors
    schedule.status = "complete";
    await schedule.update();
    return schedule;
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

    // Handle each users accounts
    for (const user of users) {
      this.logger.log(`Updating information for: ${user.username}`);
      // Sync transactions and account balances. Only do it for existing accounts.
      const userAccounts = await Account.getForUser(user);
      // If we don't have any user accounts, don't bother querying because we'll have nothing to update
      if (userAccounts.length === 0) continue;
      const accounts = await provider.get(user, false);
      for (const data of accounts) {
        this.logger.log(`Updating account from provider: ${data.account.name}`);
        let accountInDB: Account;
        try {
          accountInDB = (await Account.findOne({ where: { id: data.account.id } }))!;
          if (accountInDB == null) {
            this.logger.warn(`The account with the following ID isn't registered: ${data.account.id}`);
            throw new Error("Missing account");
          }
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
        if (data.transactions.length !== 0) await this.updateTransactionData(accountInDB, data.transactions);

        // Sync holdings if investment type
        if (accountInDB.type === AccountType.investment && data.holdings.length !== 0) await this.updateHoldingData(accountInDB, data.holdings);
      }

      // Attempt to auto categorize transactions
      await this.transactionRuleService.applyRulesToTransactions(user, undefined, true);

      this.logger.log(`Information updated successfully for: ${user.username}`);
    }
  }

  /** Updates all transaction data for the given account that matches the given transaction */
  private async updateTransactionData(accountInDb: Account, transactions: Transaction[]) {
    for (const transaction of transactions) {
      transaction.account = accountInDb;
      let transactionInDb = (await Transaction.find({ where: { id: transaction.id, account: { id: accountInDb.id } } }))[0];
      // If we aren't tracking this transaction yet, go ahead and add it
      if (transactionInDb == null) transactionInDb = await Transaction.fromPlain(transaction).insert(false);
      else {
        // Update our related holding
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
    for (const holding of holdings) {
      holding.account = accountInDb;
      let holdingInDB = (await Holding.find({ where: { symbol: holding.symbol, account: { id: accountInDb.id } } }))[0];
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
      }
    }
  }
}
