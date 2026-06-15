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

  override async get(user: User, accountsOnly: boolean) {
    this.checkPlaidClient();
    const institutions = await PlaidInstitutionAsset.find({
      where: { institution: { user: { id: user.id } } },
      relations: ["institution"],
    });
    const results: Awaited<ReturnType<PlaidProviderService["syncSingleInstitution"]>> = [];
    const updates = (await Promise.all(institutions.flatMap(async (asset) => await this.syncSingleInstitution(user, asset, accountsOnly)))).flat();
    results.push(...updates);
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
      // Fetch Holdings for the entire institution, only if this is an investment account
      if (hasInvestmentAccount) {
        try {
          await this.rateLimit(user).incrementOrError();
          const holdingsResponse = await this.plaidClient!.investmentsHoldingsGet({
            access_token: asset.accessToken,
          });
          securities = holdingsResponse.data.securities;
          allHoldings = holdingsResponse.data.holdings;
        } catch (e) {}
      }

      // Fetch all the transactions for all the accounts
      let addedTransactions: PlaidTransaction[] = [];
      let modifiedTransactions: PlaidTransaction[] = [];
      let removedTransactions: RemovedTransaction[] = [];
      try {
        if (!accountsOnly) {
          const syncData = await this.fetchAllInstitutionTransactions(user, asset);
          addedTransactions = syncData.added;
          modifiedTransactions = syncData.modified;
          removedTransactions = syncData.removed;
        }
      } catch (e) {
        this.logger.error(e);
      }

      for (const acc of accountsResponse.data.accounts) {
        let account = this.convertPlaidAccount(acc, user, asset.institution);
        let plaidAsset = await PlaidAsset.findOne({ where: { plaidAccountId: acc.account_id, account: { user: { id: user.id } } }, relations: ["account"] });

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
   *  intended to be used during linking.
   */
  async exchangeAndCreateAccounts(user: User, dto: PlaidLinkDTO) {
    this.checkPlaidClient();
    const metadata = dto.metadata;
    try {
      // Exchange public token
      await this.rateLimit(user).incrementOrError();
      const exchangeResponse = await this.plaidClient!.itemPublicTokenExchange({
        public_token: dto.publicToken,
      });

      const accessToken = exchangeResponse.data.access_token;
      const itemId = exchangeResponse.data.item_id;

      // Fetch Account details from Plaid to sync
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
          options: {
            include_optional_metadata: true,
          },
        });
        institution = await new Institution(instResponse.data.institution.url ?? this.config.url, instName, false, user).insert();
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
          const newAccount = this.convertPlaidAccount(acc, user, institution);
          // Insert our new account into the db with some history
          await newAccount.insert();
          await AccountHistory.insertForNewAccount(newAccount);
          // Insert a plaid asset so we know how it links back
          await new PlaidAsset(newAccount, acc.account_id).insert();
          return newAccount;
        }),
      );
    } catch (error) {
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

    // Save the newly acquired cursor back to the database
    if (instAsset.syncCursor !== cursor) {
      instAsset.syncCursor = cursor;
      await instAsset.update();
    }

    return { added: allAdded, modified: allModified, removed: allRemoved };
  }

  /**
   * Completely removes an institution asset link from Plaid's servers to cease billing.
   * Assumes the calling controller has already verified no active accounts rely on this item.
   */
  async unlinkInstitution(user: User, institutionId: string) {
    this.checkPlaidClient();
    const instAsset = await PlaidInstitutionAsset.findOne({
      where: { institution: { id: institutionId, user: { id: user.id } } },
      relations: ["institution"],
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
    return await Promise.all(
      transactions.map(async (t) => {
        const newTransaction = new Transaction(t.amount * -1, new Date(t.date), t.name ?? t.merchant_name, undefined, t.pending ?? false, account);
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
