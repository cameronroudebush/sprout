import { Account } from "@backend/account/model/account.model";
import { AccountSubType } from "@backend/account/model/account.sub.type";
import { AccountType } from "@backend/account/model/account.type";
import { Configuration } from "@backend/config/core";
import { Holding } from "@backend/holding/model/holding.model";
import { Institution } from "@backend/institution/model/institution.model";
import { ExchangeInstitution, ProviderBase, ProviderSyncResult } from "@backend/providers/base/core";
import { ProviderConfig } from "@backend/providers/base/model/provider.config.model";
import { ProviderSubType, ProviderType } from "@backend/providers/base/provider.type";
import { ProviderRateLimit } from "@backend/providers/base/rate-limit";
import { CoinbaseAccount } from "@backend/providers/coinbase/model/coinbase.account";
import { CoinbaseTransaction } from "@backend/providers/coinbase/model/coinbase.transaction";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { CACHE_MANAGER, Cache } from "@nestjs/cache-manager";
import { BadRequestException, Inject, Injectable, Logger, NotImplementedException } from "@nestjs/common";
import axios from "axios";
import crypto from "crypto";
import { sign } from "jsonwebtoken";

interface CoinbaseAuthContext {
  apiKey: string;
  apiKeyName: string;
}

export interface CoinbaseWalletPayload {
  id: string;
  name: string;
  accounts: CoinbaseAccount[];
}

@Injectable()
export class CoinbaseProviderService extends ProviderBase<void, void, void, CoinbaseAuthContext, CoinbaseWalletPayload, undefined> {
  /** Cache key used for the store so we can track wallet values so we don't query too often */
  static readonly CACHE_KEY = "coinbase-exchange-rates";
  protected readonly logger = new Logger("provider:coinbase:service");
  override getAppConfiguration = () => Configuration.providers.coinbase;
  config = new ProviderConfig("Coinbase", ProviderType.coinbase, ProviderSubType.crypto, "https://www.coinbase.com/", "https://portal.cdp.coinbase.com/");
  override rateLimit = (user?: User) => new ProviderRateLimit(ProviderType.coinbase, Configuration.providers.coinbase.rateLimit, user);
  override isAvailable = async (user: User) => !!user.config.coinbaseApiKey && !!user.config.coinbaseApiKeyName;

  constructor(@Inject(CACHE_MANAGER) private readonly cacheManager: Cache) {
    super();
  }

  override async generateLinkToken(): Promise<void> {
    throw new NotImplementedException("Coinbase linking is performed manually via API key's.");
  }

  /** Returns the auth context for the given user. You should null check these beforehand. */
  getAuthContext(user: User): CoinbaseAuthContext {
    return { apiKey: user.config.coinbaseApiKey!, apiKeyName: user.config.coinbaseApiKeyName! };
  }

  protected async performExchange(user: User, _payload: void): Promise<ExchangeInstitution<CoinbaseAuthContext, CoinbaseWalletPayload>[]> {
    if (!(await this.isAvailable(user))) throw new BadRequestException("Coinbase API credentials are not properly configured");

    const rawAccounts = await this.fetchCoinbaseData(user, "accounts");
    const activeAccounts = rawAccounts.filter((acc) => parseFloat(acc.balance?.amount || "0") > 0);

    const payload: CoinbaseWalletPayload = {
      id: "coinbase-primary-wallet",
      name: "Coinbase Wallet",
      accounts: activeAccounts,
    };

    return [
      {
        institutionName: "Coinbase",
        institutionUrl: this.config.url,
        authContext: this.getAuthContext(user),
        rawAccounts: [payload],
      },
    ];
  }

  protected async performSync(user: User, _asset: undefined, accountsOnly: boolean): Promise<ProviderSyncResult[]> {
    if (!(await this.isAvailable(user))) return [];
    const existingAccounts = await Account.find({
      where: { user: { id: user.id }, provider: ProviderType.coinbase },
    });
    if (existingAccounts.length === 0) return [];

    const existingAccount = existingAccounts[0]!;
    try {
      const rawAccounts = await this.fetchCoinbaseData(user, "accounts");
      const activeAccounts = rawAccounts.filter((acc) => parseFloat(acc.balance?.amount || "0") > 0);

      const payload: CoinbaseWalletPayload = {
        id: existingAccount.providerAccountId,
        name: existingAccount.name,
        accounts: activeAccounts,
      };

      const authContext = this.getAuthContext(user);
      const institution = existingAccount.institution || new Institution("https://www.coinbase.com", "Coinbase", false, user);
      const updatedAccount = await this.mapToSproutAccount(payload, authContext, user, institution);

      existingAccount.balance = updatedAccount.balance;
      existingAccount.availableBalance = updatedAccount.availableBalance;
      existingAccount.currency = "USD";

      const syncData = accountsOnly
        ? { holdings: undefined, transactions: undefined, removedTransactionIds: [] }
        : await this.fetchInitialSyncData(payload, existingAccount, authContext, user);

      if (institution.hasError) {
        institution.hasError = false;
        await institution.update();
      } else {
        institution.hasError = false;
      }

      return [
        {
          account: existingAccount,
          providerAccountId: existingAccount.providerAccountId,
          ...syncData,
        },
      ];
    } catch (error) {
      if (existingAccount.institution) {
        existingAccount.institution.hasError = true;
        await existingAccount.institution.update();
      }
      throw error;
    }
  }

  protected override extractProviderAccountId(rawAccount: CoinbaseWalletPayload): string {
    return rawAccount.id;
  }

  protected override extractAccountName(rawAccount: CoinbaseWalletPayload): string {
    return rawAccount.name;
  }

  protected async mapToSproutAccount(
    rawAccount: CoinbaseWalletPayload,
    _authContext: CoinbaseAuthContext,
    user: User,
    institution: Institution,
  ): Promise<Account> {
    const rates = await this.getUsdExchangeRates();
    let totalUsdBalance = 0;

    for (const acc of rawAccount.accounts) {
      const currency = (acc.balance?.currency || acc.currency?.code || "USD").toUpperCase();
      const cryptoAmount = parseFloat(acc.balance?.amount || "0");
      const unitPriceUsd = currency === "USD" ? 1 : (rates[currency] ?? 0);
      totalUsdBalance += cryptoAmount * unitPriceUsd;
    }

    return new Account(
      rawAccount.name || "Coinbase Wallet",
      ProviderType.coinbase,
      rawAccount.id,
      user,
      institution,
      totalUsdBalance,
      totalUsdBalance,
      AccountType.crypto,
      "USD",
      AccountSubType.wallet,
    );
  }

  protected override async fetchInitialSyncData(
    rawAccount: CoinbaseWalletPayload,
    account: Account,
    _authContext: CoinbaseAuthContext,
    user: User,
  ): Promise<Omit<ProviderSyncResult, "account">> {
    const holdings: Holding[] = [];
    const rates = await this.getUsdExchangeRates();
    const existingHoldings = await Holding.getForAccount(account);
    const existingHoldingsBySymbol = new Map(existingHoldings.map((holding) => [holding.symbol, holding]));

    for (const acc of rawAccount.accounts) {
      const cryptoAmount = parseFloat(acc.balance?.amount || "0");
      if (cryptoAmount <= 0) continue;

      const assetCode = (acc.balance?.currency || acc.currency?.code || "USD").toUpperCase();
      const unitPriceUsd = assetCode === "USD" ? 1 : (rates[assetCode] ?? 0);
      const totalMarketValueUsd = cryptoAmount * unitPriceUsd;
      let costBasis = existingHoldingsBySymbol.get(assetCode)?.costBasis ?? 0;
      try {
        const transactions = await this.fetchCoinbaseData(user, "transactions", acc.id);
        costBasis = this.calculateCostBasis(transactions, assetCode, cryptoAmount, rates) ?? costBasis;
      } catch (error) {
        this.logger.warn(`Failed to fetch Coinbase transactions for ${assetCode}; preserving previously tracked cost basis.`, error);
      }
      const averagePurchasePrice = costBasis > 0 ? costBasis / cryptoAmount : unitPriceUsd;

      const holding = new Holding(
        "USD",
        costBasis,
        `${acc.name || assetCode} Asset`,
        totalMarketValueUsd,
        averagePurchasePrice,
        cryptoAmount,
        assetCode,
        account,
      );
      holdings.push(holding);
    }
    const transactions: Transaction[] = [];
    return { transactions, removedTransactionIds: [], holdings };
  }

  protected async getInstitutionAssetsForUser(): Promise<undefined[]> {
    return [undefined]; // Force the sync loop to fire
  }

  /** Calculates current average cost basis from completed Coinbase account transactions. */
  private calculateCostBasis(transactions: CoinbaseTransaction[], assetCode: string, currentAmount: number, rates: Record<string, number>): number | null {
    let amountHeld = 0;
    let costBasis = 0;
    let foundAssetTransactions = false;

    const orderedTransactions = [...transactions].sort((a, b) => {
      if (!a.created_at || !b.created_at) return 0;
      return Date.parse(a.created_at) - Date.parse(b.created_at);
    });

    for (const transaction of orderedTransactions) {
      if (transaction.status && transaction.status !== "completed") continue;
      if (transaction.amount?.currency.toUpperCase() !== assetCode) continue;

      const transactionAmount = Number(transaction.amount.amount);
      if (!Number.isFinite(transactionAmount) || transactionAmount === 0) continue;
      foundAssetTransactions = true;

      if (transactionAmount > 0) {
        const nativeAmount = Number(transaction.native_amount?.amount);
        const nativeCurrency = transaction.native_amount?.currency.toUpperCase();
        const usdRate = nativeCurrency === "USD" ? 1 : rates[nativeCurrency ?? ""];
        const acquisitionCost = Number.isFinite(nativeAmount) && usdRate && usdRate > 0 ? Math.abs(nativeAmount) * usdRate : 0;

        amountHeld += transactionAmount;
        costBasis += acquisitionCost;
        continue;
      }

      const amountRemoved = Math.min(Math.abs(transactionAmount), amountHeld);
      if (amountRemoved > 0) {
        costBasis *= (amountHeld - amountRemoved) / amountHeld;
        amountHeld -= amountRemoved;
      }
    }

    if (!foundAssetTransactions || amountHeld <= 0 || currentAmount <= 0) return null;
    return costBasis * (currentAmount / amountHeld);
  }

  /**
   * Generic function that requests data from coinbase given the API path. Utilizes
   * the V2 API for user wallet interactions.
   */
  private async fetchCoinbaseData(user: User, resource: "accounts"): Promise<CoinbaseAccount[]>;
  private fetchCoinbaseData(user: User, resource: "transactions", accountId: string): Promise<CoinbaseTransaction[]>;
  private async fetchCoinbaseData<T>(user: User, resource: "accounts" | "transactions", accountId?: string): Promise<T[]> {
    await this.rateLimit(user).incrementOrError();
    if (!(await this.isAvailable(user))) throw new BadRequestException("Coinbase API credentials missing for user.");
    if (resource === "transactions" && !accountId) throw new BadRequestException("Coinbase account ID is required to fetch transactions.");

    const results: T[] = [];
    let startingAfter: string | undefined;
    const path = resource === "accounts" ? "/v2/accounts" : `/v2/accounts/${encodeURIComponent(accountId!)}/transactions`;
    try {
      do {
        const query = startingAfter ? `?limit=100&starting_after=${encodeURIComponent(startingAfter)}` : `?limit=100`;
        const url = `https://api.coinbase.com${path}${query}`;

        // Generate the JWT to give ask authentication
        const keyName = user.config.coinbaseApiKeyName;
        const formattedSecret = user.config.coinbaseApiKey!.replace(/\\n/g, "\n");
        const requestMethod = "GET";
        const uri = `${requestMethod.toUpperCase()} api.coinbase.com${path}`;
        const now = Math.floor(Date.now() / 1000);
        const jwt = sign({ iss: "cdp", nbf: now, exp: now + 120, sub: keyName, uri }, formattedSecret, {
          algorithm: "ES256",
          header: { kid: keyName, nonce: crypto.randomBytes(16).toString("hex") } as any,
        });
        const response = await axios.get<any>(url, { headers: { Authorization: `Bearer ${jwt}`, "Content-Type": "application/json" } });
        const items = response.data[resource] || response.data.data || [];
        results.push(...items);
        const nextUri = response.data.pagination?.next_uri;
        const nextStartingAfter = nextUri?.match(/[?&]starting_after=([^&]+)/)?.[1];
        startingAfter = response.data.pagination?.next_starting_after || (nextStartingAfter ? decodeURIComponent(nextStartingAfter) : null);
      } while (startingAfter);

      return results;
    } catch (err) {
      this.logger.error(`Failed to fetch Coinbase ${resource}`, err);
      throw err;
    }
  }

  /**
   * Fetches public spot exchange rates relative to USD from Coinbase.
   * Utilizes the CACHE_MANAGER to cache rates and prevent excessive API requests.
   *
   * @param ttl How long to store in the cache (default: 1 hour)
   */
  private async getUsdExchangeRates(ttl = 3600000): Promise<Record<string, number>> {
    try {
      // Check if exchange rates are already cached
      const cachedRates = await this.cacheManager.get<Record<string, number>>(CoinbaseProviderService.CACHE_KEY);
      if (cachedRates && Object.keys(cachedRates).length > 0) return cachedRates;
      // Fetch fresh rates from Coinbase
      const response = await axios.get<{ data: { rates: Record<string, string> } }>("https://api.coinbase.com/v2/exchange-rates?currency=USD");
      const rates: Record<string, number> = {};
      const rawRates = response.data?.data?.rates || {};
      // Coinbase returns 1 USD = X Crypto Units. To get USD per Crypto Unit: 1 / rate
      for (const [code, rateStr] of Object.entries(rawRates)) {
        const rateNum = parseFloat(rateStr);
        if (rateNum > 0) rates[code.toUpperCase()] = 1 / rateNum;
      }
      // Store in Cache Manager
      if (Object.keys(rates).length > 0) await this.cacheManager.set(CoinbaseProviderService.CACHE_KEY, rates, ttl);
      return rates;
    } catch (err) {
      this.logger.error("Failed to fetch Coinbase exchange rates", err);
      return {};
    }
  }
}
