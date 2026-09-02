import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountSubType } from "@backend/account/model/account.sub.type";
import { AccountType } from "@backend/account/model/account.type";
import { Holding } from "@backend/holding/model/holding.model";
import { Institution } from "@backend/institution/model/institution.model";
import { BaseProviderConfig } from "@backend/providers/base/config";
import { ProviderConfig } from "@backend/providers/base/model/provider.config.model";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { HttpService } from "@nestjs/axios";
import { Inject, InternalServerErrorException, Logger, NotImplementedException } from "@nestjs/common";
import { ProviderRateLimit } from "./rate-limit";

/** Standardized response payload for all provider sync operations. */
export interface ProviderSyncResult<TSyncMetadata = unknown> {
  /** The fully merged and saved Sprout account */
  account: Account;
  /** Transactions found during this sync */
  transactions?: Transaction[];
  /** Remote IDs of transactions that were deleted by the provider */
  removedTransactionIds?: string[];
  /** Holdings found during this sync */
  holdings?: Holding[];
  /** Account Id as tracked by the provider. We use our own ID's internally but still track this content */
  providerAccountId?: string;
  /** Used to pass back cursors or tokens safely after sync completion */
  syncMetadata?: TSyncMetadata;
}

/** Represents a single institution's connection data returning from a token exchange. */
export interface ExchangeInstitution<AuthContext, RawAccount> {
  /** The name of the institution provided by the remote provider */
  institutionName: string;
  /** The URL of the institution. Falls back to provider URL if missing. */
  institutionUrl?: string;
  /** Provider-specific credentials (e.g., access_token, item_id, authorization_id) */
  authContext: AuthContext;
  /** The raw accounts returned by the remote provider's API */
  rawAccounts: RawAccount[];
}

/**
 * The base class that all providers extend. It handles all shared TypeORM database operations,
 * ensuring strict encapsulation of insertion, merging, history tracking, and unlinking.
 *
 * @template LinkOptions Options required to generate a link token (e.g. redirect URL, institutionId).
 * @template LinkReturn Payload returned to the client to initialize UI (e.g. token string).
 * @template ExchangePayload Payload sent back from the client to finalize connection (e.g. public token).
 * @template AuthContext Internal connection metadata used across hooks (e.g. access_token).
 * @template RawAccount The raw account schema from the remote provider's API.
 * @template InstAsset The local TypeORM entity mapping institutions to the provider.
 * @template TSyncMetadata Payload passed back for post-sync state (e.g. sync cursors).
 */
export abstract class ProviderBase<
  LinkOptions = unknown,
  LinkReturn = unknown,
  ExchangePayload = unknown,
  AuthContext = unknown,
  RawAccount = unknown,
  InstAsset = unknown,
  TSyncMetadata = unknown,
> {
  protected readonly httpService = Inject(HttpService);
  protected abstract readonly logger: Logger;

  /** The configuration related to this provider */
  abstract config: ProviderConfig;
  /** Gets the app configuration via the Configuration class */
  abstract getAppConfiguration: () => BaseProviderConfig;
  /** The rate limit class for this provider */
  abstract rateLimit: (user?: User) => ProviderRateLimit;
  /** If this provider is available to the given user */
  abstract isAvailable: (user: User) => Promise<boolean>;

  /** Generates a provider-specific token or redirect URL to start the connection UI */
  abstract generateLinkToken(user: User, options?: LinkOptions): Promise<LinkReturn>;

  /**
   * Primary background/foreground sync route. Generalizes looping over all linked institutions,
   * retrieving updates, and updating the database.
   *
   * @param user The user initiating the sync
   * @param accountsOnly If we should skip fetching holdings/transactions
   * @param institutionId Specific institution ID to restrict the sync
   */
  async get(user: User, accountsOnly: boolean, institutionId?: string): Promise<ProviderSyncResult[]> {
    const assets = await this.getInstitutionAssetsForUser(user.id, institutionId);
    const results: ProviderSyncResult[] = [];

    for (const asset of assets) {
      try {
        const syncResults = await this.performSync(user, asset, accountsOnly);
        results.push(...syncResults);
        await this.setInstitutionError(asset, false);
      } catch (error) {
        await this.handleSyncError(asset, error);
      }
    }
    return results;
  }

  /**
   * Orchestrates the exchange of public credentials for permanent ones.
   * Generalizes DB insertion, fallback matching, history snapshotting, and transaction handling.
   *
   * @param user The user exchanging the account.
   * @param payload The provider-specific payload returning from the frontend UI.
   */
  async exchangeAndCreateAccounts(user: User, payload: ExchangePayload): Promise<ProviderSyncResult[]> {
    let exchangeData: ExchangeInstitution<AuthContext, RawAccount>[] | undefined;

    try {
      exchangeData = await this.performExchange(user, payload);
      const results: ProviderSyncResult[] = [];

      for (const instData of exchangeData) {
        // Find or create the standard Sprout Institution
        let institution = await Institution.findOne({ where: { user: { id: user.id }, name: instData.institutionName } });
        if (!institution) {
          institution = await new Institution(instData.institutionUrl || this.config.url, instData.institutionName, false, user).insert();
        }

        // Handle provider-specific linking data
        await this.upsertInstitutionAsset(institution, instData.authContext);
        institution.hasError = false;
        await institution.update();

        // Process all accounts attached to this institution
        for (const rawAccount of instData.rawAccounts) {
          const finalAccount = await this.upsertAccount(user, institution, rawAccount, instData.authContext);
          const syncData = await this.fetchInitialSyncData(rawAccount, finalAccount, instData.authContext, user);

          // Flush old holdings before snapshotting new ones to prevent duplication
          if (syncData.holdings && syncData.holdings.length > 0) {
            await Promise.all(syncData.holdings.map((h) => h.insert()));
          }

          if (syncData.transactions && syncData.transactions.length > 0) {
            syncData.transactions.forEach((t) => (t.account = finalAccount));
            await Transaction.insertMany(syncData.transactions);
          }

          results.push({
            account: finalAccount,
            holdings: syncData.holdings,
            transactions: syncData.transactions || [],
            removedTransactionIds: syncData.removedTransactionIds || [],
          });
        }
      }

      return results;
    } catch (error) {
      this.logger.error(`Failed to link accounts: ${error}`);
      if (exchangeData) {
        for (const instData of exchangeData) {
          await this.rollbackExchange(user, payload, instData.authContext);
        }
      }
      throw new InternalServerErrorException(`Failed to link accounts for ${this.config.name}.`);
    }
  }

  /**
   * Generalizes the local database deletion verification and remote provider disconnection.
   */
  async unlinkInstitution(user: User, institutionId: string): Promise<boolean> {
    const assets = await this.getInstitutionAssetsForUser(user.id, institutionId);
    if (assets.length === 0 || assets[0] == null) return true; // Already gone or unlinked

    try {
      await this.performUnlink(user, assets[0]);
      return true;
    } catch (error) {
      this.logger.error(`Failed to remote-unlink institution ${institutionId}`, error);
      return false; // Tells the controller to abort the local deletion
    }
  }

  /**
   * Finds, creates, or merges a Sprout account using remote provider identifiers.
   *
   * The sync service will normally handle this on its own. This is only intended to be used when exchanging and creating **NEW** accounts.
   */
  private async upsertAccount(user: User, institution: Institution, rawAccount: RawAccount, authContext?: AuthContext): Promise<Account> {
    const providerAccountId = this.extractProviderAccountId(rawAccount);
    // Look up existing account directly by providerAccountId
    let existingAccount = await Account.findOne({
      where: { providerAccountId, user: { id: user.id } },
    });
    // If not found by direct providerAccountId, fallback to name-matching for institution migrations
    if (!existingAccount) {
      const accountName = this.extractAccountName(rawAccount);
      existingAccount = await Account.findOne({
        where: { user: { id: user.id }, institution: { id: institution.id }, name: accountName },
      });
    }
    const incomingAccount = await this.mapToSproutAccount(rawAccount, authContext, user, institution);
    let finalAccount: Account;
    if (!existingAccount) {
      // Brand new account: Save everything and assign providerAccountId
      incomingAccount.providerAccountId = providerAccountId;
      finalAccount = await incomingAccount.insert();
      await AccountHistory.insertForNewAccount(finalAccount);
    } else {
      // Existing account: Update balance and ensure providerAccountId is up to date
      finalAccount = existingAccount;
      finalAccount.providerAccountId = providerAccountId;
      finalAccount.balance = incomingAccount.balance;
      finalAccount.availableBalance = incomingAccount.availableBalance;
      await finalAccount.update();
      await AccountHistory.insertForAccount(finalAccount);
    }
    return finalAccount;
  }

  /**
   * Attempts to guess the high-level AccountType by parsing keywords in a string (usually account name).
   * Highly useful for providers that lack strict typing.
   */
  protected determineAccountType(
    rawString: string | null | undefined,
    balance: number,
    hasHoldings: boolean,
    fallback: AccountType = AccountType.other,
  ): AccountType {
    if (!rawString) return fallback;
    const lower = rawString.toLowerCase();

    const isCredit = ["card", "credit"].some((kw) => lower.includes(kw));
    const isCrypto = ["wallet", "staked", "crypto"].some((kw) => lower.includes(kw));
    const isInvestment = ["401", "health savings", "ira", "individual", "brokerage"].some((kw) => lower.includes(kw));

    if (balance <= 0 && isCredit) return AccountType.credit;
    if (isCrypto) return AccountType.crypto;
    if (hasHoldings || isInvestment) return AccountType.investment;
    if (balance > 0) return AccountType.depository;

    return AccountType.loan;
  }

  /**
   * Normalizes raw strings (like "Roth IRA", "checking", or "Margin") into Sprout's AccountSubType.
   * Useful across providers to prevent duplicated switch statements.
   */
  protected determineAccountSubType(rawString: string | null | undefined, fallback: AccountSubType = AccountSubType.other): AccountSubType {
    if (!rawString) return fallback;

    // Strip spaces and special characters to make matching highly resilient (e.g., "Roth IRA" -> "rothira")
    const lower = rawString.toLowerCase().replace(/[^a-z0-9]/g, "");

    if (lower.includes("checking")) return AccountSubType.checking;
    if (lower.includes("savings")) return AccountSubType.savings;
    if (lower.includes("moneymarket") || lower.includes("hysa")) return AccountSubType.hysa;
    if (lower.includes("401k") || lower.includes("403b") || lower.includes("457")) return AccountSubType["401k"];
    if (lower.includes("ira") || lower.includes("roth")) return AccountSubType.ira;
    if (lower.includes("hsa") || lower.includes("fsa")) return AccountSubType.hsa;
    if (lower.includes("student")) return AccountSubType.student;
    if (lower.includes("mortgage") || lower.includes("homeequity") || lower.includes("heloc")) return AccountSubType.mortgage;
    if (lower.includes("auto")) return AccountSubType.auto;
    if (lower.includes("crypto") || lower.includes("wallet") || lower.includes("exchange")) return AccountSubType.wallet;
    if (lower.includes("loan") || lower.includes("personal") || lower.includes("lineofcredit")) return AccountSubType.personal;

    // Catch-all for investment types that don't match specific retirement labels
    if (lower.includes("brokerage") || lower.includes("individual") || lower.includes("margin") || lower.includes("investment")) {
      return AccountSubType.brokerage;
    }

    return fallback;
  }

  // ====================================================================
  // Mandatory Abstracts (Must be implemented by providers that need them)
  // ====================================================================

  /** Executes the data pull loop for a single previously-authenticated institution */
  protected abstract performSync(user: User, asset: InstAsset, accountsOnly: boolean): Promise<ProviderSyncResult[]>;
  /** Trades temporary UI credentials for permanent ones and returns raw initial accounts */
  protected abstract performExchange(user: User, payload: ExchangePayload): Promise<ExchangeInstitution<AuthContext, RawAccount>[]>;
  /** Maps remote parameters (balance, types, subtypes) to an in-memory Sprout Account entity */
  protected abstract mapToSproutAccount(rawAccount: RawAccount, authContext: AuthContext | undefined, user: User, institution: Institution): Promise<Account>;
  /** Finds all active connections to the provider */
  protected abstract getInstitutionAssetsForUser(userId: string, institutionId?: string): Promise<InstAsset[]>;

  // ====================================================================
  // Optional Methods with Safe Defaults (Implement only if needed)
  // ====================================================================

  /**
   * Previews accounts available from the provider that have not been linked to Sprout yet.
   * Override in individual provider services that support unlinked account selection (e.g. SimpleFIN, Coinbase).
   */
  async getUnlinkedAccounts(_user: User): Promise<Account[]> {
    throw new NotImplementedException("This provider doesn't support obtaining unlinked accounts. You should use their linking process.");
  }

  /** Reverts an exchange remotely if a database crash prevents us from saving it locally */
  protected async rollbackExchange(_user: User, _payload: ExchangePayload, _authContext: AuthContext): Promise<void> {}

  /** Requests the remote provider to stop tracking and billing for a specific connection */
  protected async performUnlink(_user: User, _asset: InstAsset): Promise<void> {}

  /** Intercepts provider-specific sync crashes (e.g. 401s, ITEM_LOGIN_REQUIRED) */
  protected async handleSyncError(_asset: InstAsset, error: unknown): Promise<void> {
    this.logger.error(`Sync error for provider ${this.config.name}:`, error);
  }

  /** Toggles the internal database error state flag for an institution connection */
  protected async setInstitutionError(asset: InstAsset, hasError: boolean): Promise<void> {
    if (asset && typeof asset === "object" && "institution" in asset) {
      const inst = (asset as any).institution;
      if (inst && typeof inst.hasError === "boolean") {
        inst.hasError = hasError;
        await inst.update();
      }
    }
  }

  /** Plucks the immutable remote identifier from a raw provider account */
  protected extractProviderAccountId(rawAccount: RawAccount): string {
    return (rawAccount as any)?.id || (rawAccount as any)?.accountId;
  }

  /** Plucks the raw provider account name to be used for local DB merging */
  protected extractAccountName(rawAccount: RawAccount): string {
    return (rawAccount as any)?.name || (rawAccount as any)?.accountName || "Account";
  }

  /** Grabs all immediate transactions and holdings once a new account completes DB insertion */
  protected async fetchInitialSyncData(
    _rawAccount: RawAccount,
    _account: Account,
    _authContext: AuthContext,
    _user: User,
  ): Promise<Omit<ProviderSyncResult, "account">> {
    return { transactions: [], removedTransactionIds: [], holdings: [] };
  }

  /** Upserts the connection credentials wrapper (e.g. InstitutionAsset) */
  protected async upsertInstitutionAsset(_institution: Institution, _authContext: AuthContext): Promise<void> {}

  /**
   * Optional hook called by the Sync Service AFTER all database writes succeed.
   * Perfect for committing cursors so we don't lose data on crash.
   */
  public async commitSyncMetadata(_metadata: TSyncMetadata): Promise<void> {}
}
