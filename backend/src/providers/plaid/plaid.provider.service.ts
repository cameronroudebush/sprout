import { Account } from "@backend/account/model/account.model";
import { AccountType, AccountTypeIsLiability } from "@backend/account/model/account.type";
import { Configuration } from "@backend/config/core";
import { Holding } from "@backend/holding/model/holding.model";
import { Institution } from "@backend/institution/model/institution.model";
import { ExchangeInstitution, ProviderBase, ProviderSyncResult } from "@backend/providers/base/core";
import { ProviderConfig } from "@backend/providers/base/model/provider.config.model";
import { ProviderSubType, ProviderType } from "@backend/providers/base/provider.type";
import { ProviderRateLimit } from "@backend/providers/base/rate-limit";
import { PlaidLinkDTO } from "@backend/providers/plaid/model/api/link.dto";
import { PlaidLinkTokenDTO } from "@backend/providers/plaid/model/api/link.token.dto";
import { PlaidInstitutionAsset } from "@backend/providers/plaid/model/plaid.institution.asset";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { Injectable, InternalServerErrorException, Logger } from "@nestjs/common";
import { AxiosError } from "axios";
import { isToday, parseISO, set } from "date-fns";
import {
  CountryCode,
  LinkTokenCreateRequest,
  AccountBase as PlaidAccount,
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
import { FindOptionsWhere, In } from "typeorm";

export interface PlaidLinkOptions {
  publicUrl: string;
  institutionId?: string;
}

export interface PlaidAuthContext {
  accessToken: string;
  itemId: string;
}

export interface PlaidSyncMetadata {
  institutionId: string;
  nextCursor?: string;
}

@Injectable()
export class PlaidProviderService extends ProviderBase<
  PlaidLinkOptions,
  PlaidLinkTokenDTO,
  PlaidLinkDTO,
  PlaidAuthContext,
  PlaidAccount,
  PlaidInstitutionAsset,
  PlaidSyncMetadata
> {
  protected readonly logger = new Logger("provider:plaid:service");
  override getAppConfiguration = () => Configuration.providers.plaid;
  config = new ProviderConfig("Plaid", ProviderType.plaid, ProviderSubType.bankingInvestments, "https://plaid.com/");
  override rateLimit = (user?: User) => new ProviderRateLimit(ProviderType.plaid, Configuration.providers.plaid.rateLimit, user);
  override isAvailable = async (_user: User) => !!Configuration.providers.plaid.secret && !!Configuration.providers.plaid.clientId;

  public readonly plaidClient!: PlaidApi;

  constructor() {
    super();
    if (!!Configuration.providers.plaid.secret && !!Configuration.providers.plaid.clientId) {
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

  private checkPlaidClient() {
    if (this.plaidClient == null) throw new InternalServerErrorException("Plaid is not properly configured.");
  }

  override async generateLinkToken(user: User, options?: PlaidLinkOptions): Promise<PlaidLinkTokenDTO> {
    this.checkPlaidClient();
    const webhookUrl = `${options?.publicUrl}${Configuration.server.basePath}/webhooks/plaid`;
    const baseConfig: LinkTokenCreateRequest = {
      user: { client_user_id: user.id },
      client_name: "Sprout",
      country_codes: [CountryCode.Us],
      language: "en",
      webhook: webhookUrl,
    };

    let accessToken: string | undefined;
    if (options?.institutionId) {
      const instAsset = await PlaidInstitutionAsset.findOne({
        where: { institution: { id: options.institutionId, user: { id: user.id } } },
      });
      accessToken = instAsset?.accessToken;
    }

    if (accessToken) {
      try {
        await this.rateLimit(user).incrementOrError();
        const response = await this.plaidClient.linkTokenCreate({ ...baseConfig, access_token: accessToken });
        return new PlaidLinkTokenDTO(response.data.link_token);
      } catch (error) {
        this.logger.warn(`Failed update-mode Link Token for ${options?.institutionId}. Falling back to standard mode.`);
      }
    }

    await this.rateLimit(user).incrementOrError();
    const response = await this.plaidClient.linkTokenCreate({ ...baseConfig, products: [Products.Transactions], optional_products: [Products.Investments] });
    return new PlaidLinkTokenDTO(response.data.link_token);
  }

  protected async performExchange(user: User, payload: PlaidLinkDTO): Promise<ExchangeInstitution<PlaidAuthContext, PlaidAccount>[]> {
    this.checkPlaidClient();
    await this.rateLimit(user).incrementOrError();

    const exchangeResponse = await this.plaidClient.itemPublicTokenExchange({ public_token: payload.publicToken });
    const authContext = { accessToken: exchangeResponse.data.access_token, itemId: exchangeResponse.data.item_id };

    await this.rateLimit(user).incrementOrError();

    // Fetch the actual bank URL from Plaid's metadata
    let institutionUrl = this.config.url;
    try {
      await this.rateLimit(user).incrementOrError();
      const instResponse = await this.plaidClient.institutionsGetById({
        institution_id: payload.metadata.institution.institution_id,
        country_codes: [CountryCode.Us],
        options: { include_optional_metadata: true },
      });
      institutionUrl = instResponse.data.institution.url ?? this.config.url;
    } catch (e) {
      this.logger.warn(`Could not fetch institution URL metadata for ${payload.metadata.institution.name}`);
    }
    const accountsResponse = await this.plaidClient.accountsGet({ access_token: authContext.accessToken });

    return [
      {
        institutionName: payload.metadata.institution.name,
        institutionUrl: institutionUrl,
        authContext,
        rawAccounts: accountsResponse.data.accounts,
      },
    ];
  }

  protected override async rollbackExchange(_user: User, _payload: PlaidLinkDTO, authContext: PlaidAuthContext): Promise<void> {
    if (authContext?.accessToken) {
      try {
        await this.plaidClient.itemRemove({ access_token: authContext.accessToken });
      } catch (e) {}
    }
  }

  protected async performSync(user: User, asset: PlaidInstitutionAsset, accountsOnly: boolean): Promise<ProviderSyncResult[]> {
    await this.rateLimit(user).incrementOrError();
    const accountsResponse = await this.plaidClient.accountsGet({ access_token: asset.accessToken });
    const hasInvestment = accountsResponse.data.accounts.some((acc) => this.mapType(acc.type) === AccountType.investment);

    let securities: PlaidSecurity[] | undefined;
    let allHoldings: PlaidHolding[] | undefined;

    if (hasInvestment && !accountsOnly) {
      try {
        await this.rateLimit(user).incrementOrError();
        const holdingsRes = await this.plaidClient.investmentsHoldingsGet({ access_token: asset.accessToken });
        securities = holdingsRes.data.securities;
        allHoldings = holdingsRes.data.holdings;
      } catch (e) {
        const plaidError = (e as AxiosError).response?.data as PlaidError;
        this.logger.warn(`Failed to fetch holdings for ${asset.institution.name}: ${plaidError.error_message}`);
      }
    }

    let added: PlaidTransaction[] = [];
    let modified: PlaidTransaction[] = [];
    let removed: RemovedTransaction[] = [];
    let nextCursor = asset.syncCursor;

    if (!accountsOnly) {
      const syncData = await this.fetchAllInstitutionTransactions(user, asset);
      added = syncData.added;
      modified = syncData.modified;
      removed = syncData.removed;
      asset.syncCursor = syncData.nextCursor;
    }

    const results: ProviderSyncResult[] = [];
    for (const rawAccount of accountsResponse.data.accounts) {
      const finalAccount = await this.mapToSproutAccount(rawAccount, { accessToken: asset.accessToken, itemId: asset.itemId }, user, asset.institution);

      const existingAccount = await Account.findOne({
        where: { providerAccountId: rawAccount.account_id, user: { id: user.id } },
      });
      if (existingAccount) finalAccount.id = existingAccount.id;

      const accountTransactions = added.concat(modified).filter((t) => t.account_id === rawAccount.account_id);
      const transactions = await this.convertPlaidTransactions(accountTransactions, finalAccount, user);

      // Translate Plaid removed IDs into our internally generated DB UUIDs
      const removedPlaidIds = removed.filter((t) => t.account_id === rawAccount.account_id).map((t) => t.transaction_id);
      let removedTransactionIds: string[] = [];

      if (removedPlaidIds.length > 0) {
        const removedTxs = await Transaction.find({
          where: {
            providerId: In(removedPlaidIds),
            account: { id: finalAccount.id },
          },
          select: { id: true }, // We only need the internal DB ID to pass to ProviderSyncService
        });
        removedTransactionIds = removedTxs.map((t) => t.id);
      }

      const accountHoldings =
        allHoldings && securities
          ? allHoldings.filter((h) => h.account_id === rawAccount.account_id).map((h) => this.convertPlaidHolding(h, securities!, finalAccount))
          : undefined;

      results.push({
        account: finalAccount,
        providerAccountId: rawAccount.account_id,
        syncMetadata: { institutionId: asset.institution.id, nextCursor },
        holdings: accountHoldings,
        transactions,
        removedTransactionIds,
      });
    }

    return results;
  }

  override async commitSyncMetadata(metadata: PlaidSyncMetadata): Promise<void> {
    if (metadata.nextCursor && metadata.institutionId) {
      const asset = await PlaidInstitutionAsset.findOne({ where: { institution: { id: metadata.institutionId } } });
      if (asset) {
        asset.syncCursor = metadata.nextCursor;
        await asset.update();
      }
    }
  }

  protected override async performUnlink(user: User, asset: PlaidInstitutionAsset): Promise<void> {
    await this.rateLimit(user).incrementOrError();
    await this.plaidClient.itemRemove({ access_token: asset.accessToken });
  }

  protected override async handleSyncError(asset: PlaidInstitutionAsset, error: unknown): Promise<void> {
    const plaidError = (error as AxiosError).response?.data as PlaidError;
    if (plaidError && plaidError.error_type === "ITEM_ERROR") {
      const criticalErrors = ["ITEM_LOGIN_REQUIRED", "PENDING_EXPIRATION", "INVALID_ACCESS_TOKEN", "ITEM_NOT_FOUND"];
      if (criticalErrors.includes(plaidError.error_code)) {
        await this.setInstitutionError(asset, true);
        return;
      }
    }
    this.logger.error(`Failed to sync Plaid for institution ${asset.institution.name}:`, error);
  }

  protected override async setInstitutionError(asset: PlaidInstitutionAsset, hasError: boolean): Promise<void> {
    asset.institution.hasError = hasError;
    await asset.institution.update();
  }

  protected override extractProviderAccountId(rawAccount: PlaidAccount): string {
    return rawAccount.account_id;
  }
  protected override extractAccountName(rawAccount: PlaidAccount): string {
    return rawAccount.name;
  }

  protected async mapToSproutAccount(acc: PlaidAccount, _authContext: PlaidAuthContext | undefined, user: User, institution: Institution): Promise<Account> {
    const accType = this.mapType(acc.type);
    const isLiability = AccountTypeIsLiability(accType);
    return new Account(
      acc.name,
      ProviderType.plaid,
      acc.account_id,
      user,
      institution,
      (acc.balances.current || 0) * (isLiability ? -1 : 1),
      0,
      accType,
      acc.balances.iso_currency_code || "USD",
      this.determineAccountSubType(acc.subtype),
    );
  }

  protected override async fetchInitialSyncData(
    _rawAccount: PlaidAccount,
    _account: Account,
    _authContext: PlaidAuthContext,
    _user: User,
  ): Promise<Omit<ProviderSyncResult, "account">> {
    return { transactions: [], removedTransactionIds: [], holdings: [] }; // Initial transactions caught on first sync
  }

  protected async getInstitutionAssetsForUser(userId: string, institutionId?: string): Promise<PlaidInstitutionAsset[]> {
    const where: FindOptionsWhere<PlaidInstitutionAsset> = { institution: { user: { id: userId } } };
    if (institutionId) where.id = institutionId;
    return await PlaidInstitutionAsset.find({ where, relations: { institution: true } });
  }

  protected override async upsertInstitutionAsset(institution: Institution, authContext: PlaidAuthContext): Promise<void> {
    let asset = await PlaidInstitutionAsset.findOne({ where: { institution: { id: institution.id } } });
    if (!asset) {
      await new PlaidInstitutionAsset(institution, authContext.accessToken, authContext.itemId).insert();
    } else {
      if (asset.itemId !== authContext.itemId) {
        try {
          await this.plaidClient.itemRemove({ access_token: asset.accessToken });
        } catch (e) {}
        asset.itemId = authContext.itemId;
      }
      asset.accessToken = authContext.accessToken;
      await asset.update();
    }
  }

  private async fetchAllInstitutionTransactions(user: User, instAsset: PlaidInstitutionAsset) {
    let added: PlaidTransaction[] = [];
    let modified: PlaidTransaction[] = [];
    let removed: RemovedTransaction[] = [];
    let hasMore = true;
    let cursor = instAsset.syncCursor || undefined;

    while (hasMore) {
      await this.rateLimit(user).incrementOrError();
      const response = await this.plaidClient.transactionsSync({
        access_token: instAsset.accessToken,
        cursor,
        count: 100,
        options: { include_personal_finance_category: true },
      });
      added = added.concat(response.data.added);
      modified = modified.concat(response.data.modified);
      removed = removed.concat(response.data.removed);
      cursor = response.data.next_cursor;
      hasMore = response.data.has_more;
    }
    return { added, modified, removed, nextCursor: cursor };
  }

  private async convertPlaidTransactions(transactions: PlaidTransaction[], account: Account, user: User) {
    const now = new Date();
    return await Promise.all(
      transactions.map(async (t) => {
        if (t.pending_transaction_id) {
          const pendingTx = await Transaction.findOne({ where: { providerId: t.pending_transaction_id, account: { user: { id: user.id } } } });
          if (pendingTx) await pendingTx.remove();
        }
        const parsedDate = parseISO(t.authorized_date ?? t.date);
        const transactionDate = isToday(parsedDate)
          ? set(parsedDate, { hours: now.getHours(), minutes: now.getMinutes(), seconds: now.getSeconds(), milliseconds: now.getMilliseconds() })
          : parsedDate;
        const newTx = new Transaction(t.amount * -1, transactionDate, t.name ?? t.merchant_name, undefined, t.pending ?? false, account);
        newTx.providerId = t.transaction_id;
        newTx.extra = { code: t.transaction_code, location: t.location, website: t.website, authorizedDate: t.authorized_date, date: t.date };
        return newTx;
      }),
    );
  }

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

  /**
   * Iterates through every Plaid item connection in the database and updates
   * its destination webhook URL to match a new server domain layout.
   */
  async updateAllItemWebhooks(newBaseUrl: string): Promise<{ successCount: number; failureCount: number }> {
    if (!this.plaidClient) throw new InternalServerErrorException("Plaid is not properly configured.");

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
}
