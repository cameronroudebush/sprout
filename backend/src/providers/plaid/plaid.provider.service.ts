import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountSubType } from "@backend/account/model/account.sub.type";
import { AccountType, AccountTypeIsLiability } from "@backend/account/model/account.type";
import { Configuration } from "@backend/config/core";
import { Holding } from "@backend/holding/model/holding.model";
import { Institution } from "@backend/institution/model/institution.model";
import { ProviderConfig } from "@backend/providers/base/model/provider.config.model";
import { ProviderSubType, ProviderType } from "@backend/providers/base/provider.type";
import { PlaidLinkDTO } from "@backend/providers/plaid/model/api/link.dto";
import { PlaidLinkTokenDTO } from "@backend/providers/plaid/model/api/link.token.dto";
import { PlaidAsset } from "@backend/providers/plaid/model/plaid.asset";
import { PlaidInstitutionAsset } from "@backend/providers/plaid/model/plaid.institution.asset";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { Injectable, InternalServerErrorException, Logger } from "@nestjs/common";
import { AxiosError } from "axios";
import { isToday, parseISO, set } from "date-fns";
import { merge } from "lodash";
import {
  CountryCode,
  LinkTokenCreateRequest,
  AccountBase as PlaidAccount,
  AccountSubtype as PlaidAccountSubType,
  AccountType as PlaidAccountType,
  PlaidApi,
  Configuration as PlaidConfig,
  PlaidError,
  Holding as PlaidHolding,
  Security as PlaidSecurity,
  Transaction as PlaidTransaction,
  Products,
  RemovedTransaction,
} from "plaid";
import { FindOptionsWhere } from "typeorm";
import { ProviderBase } from "../base/core";
import { ProviderRateLimit } from "../base/rate-limit";

/**
 * This provider adds account linking via plaid.
 */
@Injectable()
export class PlaidProviderService extends ProviderBase {
  override getAppConfiguration = () => Configuration.providers.plaid;
  private readonly logger = new Logger("provider:plaid:service");
  config = new ProviderConfig(
    "Plaid",
    ProviderType.plaid,
    ProviderSubType.bankingInvestments,
    "https://plaid.com/",
    "https://plaid.com/assets/img/favicons/apple-touch-icon.png",
  );
  override rateLimit = (user?: User) => new ProviderRateLimit(ProviderType.plaid, Configuration.providers.plaid.rateLimit, user);
  override isAvailable = async (_user: User) => !!Configuration.providers.plaid.secret && !!Configuration.providers.plaid.clientId;

  /** The client for talking with plaid for account info */
  public readonly plaidClient!: PlaidApi;

  constructor() {
    super();
    if (!!Configuration.providers.plaid.secret && !!Configuration.providers.plaid.clientId) {
      this.logger.log("Plaid is configured. Initializing client.");
      this.plaidClient = new PlaidApi(
        new PlaidConfig({
          basePath: Configuration.providers.plaid.environment,
          baseOptions: {
            headers: {
              "PLAID-CLIENT-ID": Configuration.providers.plaid.clientId,
              "PLAID-SECRET": Configuration.providers.plaid.secret,
            },
          },
        }),
      );
    }
  }

  /** Checks if the plaid client is configured and throws an error if not */
  private checkPlaidClient() {
    if (this.plaidClient == null) throw new InternalServerErrorException("Plaid is not properly configured.");
  }

  override async get(user: User, accountsOnly: boolean, institutionId: string) {
    this.checkPlaidClient();
    const where: FindOptionsWhere<PlaidInstitutionAsset> = { institution: { user: { id: user.id } } };
    if (institutionId) where.id = institutionId;
    const institutions = await PlaidInstitutionAsset.find({ where, relations: { institution: true } });
    // Run sequentially to prevent 429's
    const results: Awaited<ReturnType<PlaidProviderService["syncSingleInstitution"]>> = [];
    for (const asset of institutions) {
      const updates = await this.syncSingleInstitution(user, asset, accountsOnly);
      results.push(...updates);
    }
    return results;
  }

  /** Syncs a single institution */
  private async syncSingleInstitution(user: User, asset: PlaidInstitutionAsset, accountsOnly: boolean) {
    const results = [];
    try {
      // Fetch Balances/Accounts
      await this.rateLimit(user).incrementOrError();
      const accountsResponse = await this.plaidClient!.accountsGet({
        access_token: asset.accessToken,
      });

      const hasInvestmentAccount = accountsResponse.data.accounts.some((acc) => this.mapType(acc.type) === AccountType.investment);
      let allHoldings: PlaidHolding[] | undefined = undefined;
      let securities: PlaidSecurity[] | undefined = undefined;

      // In a production background sync, skip holdings unless explicitly requested via webhooks or manual refresh
      if (hasInvestmentAccount && !accountsOnly) {
        try {
          await this.rateLimit(user).incrementOrError();
          const holdingsResponse = await this.plaidClient!.investmentsHoldingsGet({
            access_token: asset.accessToken,
          });
          securities = holdingsResponse.data.securities;
          allHoldings = holdingsResponse.data.holdings;
        } catch (e) {
          this.logger.warn(`Failed to fetch holdings for ${asset.institution.name}`);
        }
      }

      // Fetch all the transactions for all the accounts
      let addedTransactions: PlaidTransaction[] = [];
      let modifiedTransactions: PlaidTransaction[] = [];
      let removedTransactions: RemovedTransaction[] = [];
      let newCursor = asset.syncCursor;

      try {
        if (!accountsOnly) {
          const syncData = await this.fetchAllInstitutionTransactions(user, asset);
          addedTransactions = syncData.added;
          modifiedTransactions = syncData.modified;
          removedTransactions = syncData.removed;
          newCursor = syncData.nextCursor;
        }
      } catch (e) {
        this.logger.error(e);
      }

      for (const acc of accountsResponse.data.accounts) {
        let account = this.convertPlaidAccount(acc, user, asset.institution);
        let plaidAsset = await PlaidAsset.findOne({
          where: { plaidAccountId: acc.account_id, account: { user: { id: user.id } } },
          relations: { account: true },
        });

        // This is a new account. Handle it like so.
        if (plaidAsset == null) {
          account = await account.insert();
          plaidAsset = await new PlaidAsset(account, acc.account_id).insert();
        } else {
          account = merge(plaidAsset.account, account);
        }

        // Convert added + modified transactions. These will be upserted.
        const accountTransactions = addedTransactions.concat(modifiedTransactions).filter((t) => t.account_id === acc.account_id);
        const transactions = await this.convertPlaidTransactions(accountTransactions, account, user);
        const removedTransactionIds = removedTransactions.filter((t) => t.account_id === acc.account_id).map((t) => t.transaction_id);

        // Overarching holding objects considering securities
        const accountHoldings =
          allHoldings && securities
            ? allHoldings.filter((h) => h.account_id === acc.account_id).map((h) => this.convertPlaidHolding(h, securities, account))
            : undefined;

        results.push({
          account,
          holdings: accountHoldings,
          transactions: transactions,
          removedTransactionIds: removedTransactionIds,
          newCursor: newCursor,
        });

        // Successful update, make sure we don't track as an error
        account.institution.hasError = false;
      }
    } catch (e) {
      this.logger.error(e);
      const plaidError = (e as AxiosError).response?.data as PlaidError;
      if (plaidError && plaidError.error_type === "ITEM_ERROR") {
        this.logger.warn(`Plaid Item Error for ${asset.institution.name}: ${plaidError.error_code}`);
        // These specific codes mean the user MUST take action in the UI
        const criticalErrors = ["ITEM_LOGIN_REQUIRED", "PENDING_EXPIRATION", "INVALID_ACCESS_TOKEN"];
        if (criticalErrors.includes(plaidError.error_code)) asset.institution.hasError = true;
      }
    }

    return results;
  }

  /** Generates a short-lived link_token to initialize Plaid Link on the mobile/web frontend. */
  async generateLinkToken(user: User, publicUrl: string, institutionId?: string) {
    this.checkPlaidClient();
    const webhookUrl = `${publicUrl}${Configuration.server.basePath}/webhooks/plaid`;
    this.logger.debug(`Plaid webhook configured to ${webhookUrl}`);
    const config = {
      user: { client_user_id: user.id },
      client_name: "Sprout",
      country_codes: [CountryCode.Us],
      language: "en",
      webhook: webhookUrl,
      // Allows us to specify theme. Might add feature for this in the future
      // link_customization_name: user.config.themeStyle.toString(),
    } as LinkTokenCreateRequest;
    try {
      await this.rateLimit(user).incrementOrError();
      if (institutionId) {
        const instAsset = await PlaidInstitutionAsset.findOne({
          where: { institution: { id: institutionId, user: { id: user.id } } },
        });
        if (!instAsset) throw new InternalServerErrorException("Existing Plaid connection not found.");
        config.access_token = instAsset.accessToken;
      } else {
        config.products = [Products.Transactions];
      }
      const response = await this.plaidClient!.linkTokenCreate(config);
      return new PlaidLinkTokenDTO(response.data.link_token);
    } catch (error) {
      throw new InternalServerErrorException(`Could not initialize Plaid: ${error as AxiosError}`);
    }
  }

  /**
   * Exchanges the public_token from the frontend for an access_token,
   * then fetches and saves the chosen accounts as new accounts for Sprout. Only
   * intended to be used during linking.
   */
  async exchangeAndCreateAccounts(user: User, dto: PlaidLinkDTO) {
    this.checkPlaidClient();
    const metadata = dto.metadata;
    let accessToken: string | undefined;
    let itemId: string | undefined;

    // Isolate token exchange to prevent DB errors from leaving ghost items on Plaid servers
    try {
      await this.rateLimit(user).incrementOrError();
      const exchangeResponse = await this.plaidClient!.itemPublicTokenExchange({
        public_token: dto.publicToken,
      });

      accessToken = exchangeResponse.data.access_token;
      itemId = exchangeResponse.data.item_id;
    } catch (error) {
      throw new InternalServerErrorException(`Failed to exchange public token. ${error}`);
    }

    // Secondary block handles local operations. If this fails, the Plaid item is wiped.
    try {
      await this.rateLimit(user).incrementOrError();
      const accountsResponse = await this.plaidClient!.accountsGet({
        access_token: accessToken,
      });

      // Create/Find Institution
      const instName = metadata.institution.name;
      const plaidInstId = metadata.institution.institution_id;
      let institution = await Institution.findOne({ where: { user: { id: user.id }, name: instName } });

      if (!institution) {
        await this.rateLimit(user).incrementOrError();
        const instResponse = await this.plaidClient!.institutionsGetById({
          institution_id: plaidInstId,
          country_codes: [CountryCode.Us],
          options: { include_optional_metadata: true },
        });
        institution = await new Institution(instResponse.data.institution.url ?? this.config.url, instName, false, user).insert();
      } else {
        // Remove duplicate institutions if user bypassed frontend update UI
        const existingAsset = await PlaidInstitutionAsset.findOne({ where: { institution: { id: institution.id } } });
        if (existingAsset && existingAsset.itemId !== itemId) {
          await this.plaidClient.itemRemove({ access_token: accessToken });
          accessToken = undefined; // Clear so the catch block doesn't try to remove it again
          throw new InternalServerErrorException("This bank is already linked. If you need to fix a connection, please use the update settings.");
        }
      }

      // Store the Plaid credential linked to this institution
      let plaidInstitutionAsset = await PlaidInstitutionAsset.findOne({ where: { institution: { id: institution.id } } });
      if (!plaidInstitutionAsset) {
        await new PlaidInstitutionAsset(institution, accessToken, itemId).insert();
      } else {
        // Update token in case it changed during a re-auth flow
        plaidInstitutionAsset.accessToken = accessToken;
        plaidInstitutionAsset.itemId = itemId;
        await plaidInstitutionAsset.update();
      }

      // We don't both to get transactions here because they won't be ready. We'll catch them on the next sync

      return await Promise.all(
        accountsResponse.data.accounts.map(async (acc) => {
          // Upsert logic to prevent duplicate checking/savings on update flow
          let plaidAsset = await PlaidAsset.findOne({
            where: { plaidAccountId: acc.account_id, account: { user: { id: user.id } } },
            relations: { account: true },
          });

          if (!plaidAsset) {
            // This is a genuinely new account under this institution
            const newAccount = this.convertPlaidAccount(acc, user, institution);
            await newAccount.insert();
            await AccountHistory.insertForNewAccount(newAccount);
            await new PlaidAsset(newAccount, acc.account_id).insert();
            return newAccount;
          } else {
            // This account already exists. Update its balance/details instead of creating a duplicate
            const accountToUpdate = this.convertPlaidAccount(acc, user, institution);
            const mergedAccount = merge(plaidAsset.account, accountToUpdate);
            await mergedAccount.update();
            await AccountHistory.insertForAccount(plaidAsset.account);
            return mergedAccount;
          }
        }),
      );
    } catch (error) {
      // If a database crash or validation error occurs, ensure we wipe the orphaned Plaid item
      if (accessToken)
        try {
          await this.plaidClient!.itemRemove({ access_token: accessToken });
        } catch (e) {
          this.logger.error("Failed to clean up orphaned Plaid item after DB crash.", e);
        }
      throw new InternalServerErrorException(`Failed to link Plaid accounts. ${error}`);
    }
  }

  /**
   * Fetches all transactions for an institution's access_token
   * for the last N days, handling Plaid's pagination.
   */
  private async fetchAllInstitutionTransactions(user: User, instAsset: PlaidInstitutionAsset) {
    let allAdded: PlaidTransaction[] = [];
    let allModified: PlaidTransaction[] = [];
    let allRemoved: RemovedTransaction[] = [];

    let hasMore = true;
    let cursor = instAsset.syncCursor || undefined;

    while (hasMore) {
      await this.rateLimit(user).incrementOrError();
      const response = await this.plaidClient!.transactionsSync({
        access_token: instAsset.accessToken,
        cursor: cursor,
        count: 100,
        options: {
          include_personal_finance_category: true,
        },
      });

      allAdded = allAdded.concat(response.data.added);
      allModified = allModified.concat(response.data.modified);
      allRemoved = allRemoved.concat(response.data.removed);

      cursor = response.data.next_cursor;
      hasMore = response.data.has_more;
    }

    return { added: allAdded, modified: allModified, removed: allRemoved, nextCursor: cursor };
  }

  /**
   * Completely removes an institution asset link from Plaid's servers to cease billing.
   * Assumes the calling controller has already verified no active accounts rely on this item.
   */
  async unlinkInstitution(user: User, institutionId: string) {
    this.checkPlaidClient();
    const instAsset = await PlaidInstitutionAsset.findOne({
      where: { institution: { id: institutionId, user: { id: user.id } } },
      relations: { institution: true },
    });
    // If it's already gone, silently return true so the controller can finish deleting the institution
    if (!instAsset) return true;
    this.logger.log(`Removing Plaid Item billing connection for: ${instAsset.institution.name}`);
    // Tell Plaid to stop tracking and billing for this Item
    try {
      await this.rateLimit(user).incrementOrError();
      await this.plaidClient.itemRemove({
        access_token: instAsset.accessToken,
      });
      return true;
    } catch (error) {
      const axiosError = error as AxiosError;
      const plaidError = axiosError.response?.data as PlaidError;
      this.logger.error(plaidError);
      return false;
    }
  }

  /**
   * Iterates through every Plaid item connection in the database and updates
   * its destination webhook URL to match a new server domain layout.
   */
  async updateAllItemWebhooks(newBaseUrl: string): Promise<{ successCount: number; failureCount: number }> {
    this.checkPlaidClient();
    const assets = await PlaidInstitutionAsset.find({
      relations: { institution: true },
    });
    const targetWebhookUrl = `${newBaseUrl}${Configuration.server.basePath}/webhooks/plaid`;
    this.logger.log(`Starting bulk update of Plaid webhooks to target: ${targetWebhookUrl}`);
    let successCount = 0;
    let failureCount = 0;
    for (const asset of assets) {
      try {
        await this.plaidClient.itemWebhookUpdate({
          access_token: asset.accessToken,
          webhook: targetWebhookUrl,
        });
        this.logger.debug(`Successfully updated webhook for Plaid Item ID: ${asset.itemId} (${asset.institution?.name})`);
        successCount++;
      } catch (error) {
        this.logger.error(`Failed to update webhook for Plaid Item ID: ${asset.itemId}`, error);
        failureCount++;
      }
    }
    return { successCount, failureCount };
  }

  /** Converts the given plaid account to Sprout's local model. Does not insert. */
  private convertPlaidAccount(acc: PlaidAccount, user: User, institution: Institution) {
    const accType = this.mapType(acc.type);
    const isLiability = AccountTypeIsLiability(accType);
    const account = new Account(
      acc.name,
      ProviderType.plaid,
      user,
      institution,
      (acc.balances.current || 0) * (isLiability ? -1 : 1),
      0,
      accType,
      acc.balances.iso_currency_code || "USD",
      this.mapSubType(acc.subtype),
    );
    return account;
  }

  /** Converts Plaid's transaction format to Sprout's local Transaction model */
  private async convertPlaidTransactions(transactions: PlaidTransaction[], account: Account, _user: User) {
    const now = new Date();

    return await Promise.all(
      transactions.map(async (t) => {
        // Parse Plaid's 'YYYY-MM-DD' safely as a local date profile
        const parsedDate = parseISO(t.date);

        // If it's today, inject the current live system time. Otherwise, parseISO automatically defaults it to local midnight (00:00:00).
        const transactionDate = isToday(parsedDate)
          ? set(parsedDate, {
              hours: now.getHours(),
              minutes: now.getMinutes(),
              seconds: now.getSeconds(),
              milliseconds: now.getMilliseconds(),
            })
          : parsedDate;

        const newTransaction = new Transaction(t.amount * -1, transactionDate, t.name ?? t.merchant_name, undefined, t.pending ?? false, account);
        newTransaction.id = t.transaction_id;
        newTransaction.extra = { code: t.transaction_code, location: t.location };
        return newTransaction;
      }),
    );
  }

  /** Converts Plaid Holding + Security data into Sprout Holdings */
  private convertPlaidHolding(holding: PlaidHolding, securities: PlaidSecurity[], account: Account) {
    const security = securities.find((s) => s.security_id === holding.security_id);

    return new Holding(
      holding.iso_currency_code || "USD",
      holding.cost_basis || 0,
      security?.name || "Unknown Security",
      holding.institution_value || 0,
      holding.institution_price || 0,
      holding.quantity || 0,
      security?.ticker_symbol || "???",
      account,
    );
  }

  /** Maps primary plaid types to Sprout's internal account types */
  private mapType(plaidType: PlaidAccountType): AccountType {
    switch (plaidType) {
      case PlaidAccountType.Credit:
        return AccountType.credit;
      case PlaidAccountType.Depository:
        return AccountType.depository;
      case PlaidAccountType.Brokerage:
      case PlaidAccountType.Investment:
        return AccountType.investment;
      case PlaidAccountType.Loan:
        return AccountType.loan;
      default:
        return AccountType.other;
    }
  }

  /** Maps subtypes from plaid to Sprout's internal sub types */
  private mapSubType(plaidSub: PlaidAccountSubType | null): AccountSubType {
    switch (plaidSub) {
      case PlaidAccountSubType.Savings:
        return AccountSubType.savings;
      case PlaidAccountSubType.Checking:
        return AccountSubType.checking;
      case PlaidAccountSubType.MoneyMarket:
        return AccountSubType.hysa;
      case PlaidAccountSubType._401k:
        return AccountSubType["401k"];
      case PlaidAccountSubType.Brokerage:
        return AccountSubType.brokerage;
      case PlaidAccountSubType.Ira:
        return AccountSubType.ira;
      case PlaidAccountSubType.Hsa:
        return AccountSubType.hsa;
      case PlaidAccountSubType.Student:
        return AccountSubType.student;
      case PlaidAccountSubType.Mortgage:
        return AccountSubType.mortgage;
      case PlaidAccountSubType.Loan:
        return AccountSubType.personal;
      case PlaidAccountSubType.Auto:
        return AccountSubType.auto;
      case PlaidAccountSubType.CryptoExchange:
        return AccountSubType.wallet;
      default:
        return AccountSubType.other;
    }
  }
}
