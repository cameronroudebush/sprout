import { Account } from "@backend/account/model/account.model";
import { AccountSubType } from "@backend/account/model/account.sub.type";
import { AccountType } from "@backend/account/model/account.type";
import { Configuration } from "@backend/config/core";
import { Holding } from "@backend/holding/model/holding.model";
import { Institution } from "@backend/institution/model/institution.model";
import { ProviderBase, ProviderSyncResult } from "@backend/providers/base/core";
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
import * as crypto from "crypto";
import { sign } from "jsonwebtoken";

interface CoinbaseAuthContext {
  apiKey: string;
  apiKeyName: string;
}

@Injectable()
export class CoinbaseProviderService extends ProviderBase<void, void, string[], CoinbaseAuthContext, CoinbaseAccount, undefined> {
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

  override async getUnlinkedAccounts(user: User): Promise<Account[]> {
    if (!(await this.isAvailable(user))) return [];
    const existingAccounts = await Account.find({ where: { user: { id: user.id }, provider: ProviderType.coinbase } });
    const existingProviderAccountIds = existingAccounts.map((a) => a.providerAccountId).filter(Boolean);
    const accounts = await this.fetchCoinbaseData(user, "accounts");
    const unlinked = accounts.filter((acc) => {
      const cryptoAmount = parseFloat(acc.balance?.amount || "0");
      return acc.id && !existingProviderAccountIds.includes(acc.id) && cryptoAmount > 0;
    });
    const unlinkedAccounts: Account[] = [];
    for (const rawAccount of unlinked) {
      const institution = new Institution("https://www.coinbase.com", "Coinbase", false, user);
      institution.id = crypto.randomUUID();
      const acc = await this.mapToSproutAccount(rawAccount, this.getAuthContext(user), user, institution);
      acc.id = acc.providerAccountId;
      unlinkedAccounts.push(acc);
    }
    return unlinkedAccounts;
  }

  protected async performExchange(user: User, accountIdsToLink: string[]) {
    if (!(await this.isAvailable(user))) throw new BadRequestException("Coinbase API credentials are not properly configured");
    const accounts = await this.fetchCoinbaseData(user, "accounts");
    const selectedAccounts = accounts.filter((acc) => acc.id && accountIdsToLink.includes(acc.id));

    return [
      {
        institutionName: "Coinbase",
        institutionUrl: this.config.url,
        authContext: this.getAuthContext(user),
        rawAccounts: selectedAccounts,
      },
    ];
  }

  protected async performSync(user: User, _asset: undefined, accountsOnly: boolean): Promise<ProviderSyncResult[]> {
    if (!(await this.isAvailable(user))) return [];
    const accounts = await this.fetchCoinbaseData(user, "accounts");
    const existingAccounts = await Account.find({
      where: { user: { id: user.id }, provider: ProviderType.coinbase },
    });
    const existingMap = new Map(existingAccounts.map((a) => [a.providerAccountId, a]));
    const results: ProviderSyncResult[] = [];
    const authContext = this.getAuthContext(user);

    for (const rawAccount of accounts) {
      if (!rawAccount.id || !existingMap.has(rawAccount.id)) continue;

      const existingAccount = existingMap.get(rawAccount.id)!;
      const institution = existingAccount.institution || new Institution("https://www.coinbase.com", "Coinbase", false, user);
      const updatedAccount = await this.mapToSproutAccount(rawAccount, authContext, user, institution);

      // Retain existing entity ID for updates and save converted USD balance
      existingAccount.balance = updatedAccount.balance;
      existingAccount.availableBalance = updatedAccount.availableBalance;
      existingAccount.currency = "USD";

      const syncData = accountsOnly
        ? { holdings: undefined, transactions: undefined, removedTransactionIds: [] }
        : await this.fetchInitialSyncData(rawAccount, existingAccount, authContext, user);

      results.push({
        account: existingAccount,
        providerAccountId: rawAccount.id,
        ...syncData,
      });
    }

    return results;
  }

  protected override extractProviderAccountId(rawAccount: CoinbaseAccount): string {
    return rawAccount.id || "";
  }

  protected override extractAccountName(rawAccount: CoinbaseAccount): string {
    return `${rawAccount.name || rawAccount.currency?.code} Wallet`;
  }

  protected async mapToSproutAccount(rawAccount: CoinbaseAccount, _authContext: CoinbaseAuthContext, user: User, institution: Institution): Promise<Account> {
    const rawCurrency = (rawAccount.balance?.currency || rawAccount.currency?.code || "USD").toUpperCase();
    const cryptoAmount = parseFloat(rawAccount.balance?.amount || "0");
    const rates = await this.getUsdExchangeRates();

    // Convert crypto quantity to USD value using current exchange rates
    let usdValue = cryptoAmount;
    if (rawCurrency !== "USD") {
      const unitPriceUsd = rates?.[rawCurrency] ?? 0;
      usdValue = cryptoAmount * unitPriceUsd;
    }

    return new Account(
      `${rawAccount.name || rawCurrency}`,
      ProviderType.coinbase,
      rawAccount.id,
      user,
      institution,
      usdValue,
      usdValue,
      AccountType.crypto,
      "USD",
      rawAccount.name.toLowerCase().includes("staked") ? AccountSubType.staking : AccountSubType.wallet,
    );
  }

  protected override async fetchInitialSyncData(
    rawAccount: CoinbaseAccount,
    account: Account,
    _authContext: CoinbaseAuthContext,
    _user: User,
  ): Promise<Omit<ProviderSyncResult, "account">> {
    const holdings: Holding[] = [];
    const cryptoAmount = parseFloat(rawAccount.balance?.amount || "0");
    const rates = await this.getUsdExchangeRates();

    if (cryptoAmount > 0) {
      const assetCode = (rawAccount.balance?.currency || "USD").toUpperCase();
      const unitPriceUsd = assetCode === "USD" ? 1 : (rates?.[assetCode] ?? 0);
      const totalMarketValueUsd = cryptoAmount * unitPriceUsd;

      const holding = new Holding(
        "USD",
        0, // costBasis
        `${assetCode} Asset`,
        totalMarketValueUsd, // institutionValue (in USD)
        unitPriceUsd, // institutionPrice (price per crypto unit in USD)
        cryptoAmount, // quantity (crypto units)
        assetCode, // ticker symbol
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

  /**
   * Generic function that requests data from coinbase given the API path. Utilizes
   * the V2 API for user wallet interactions.
   */
  private async fetchCoinbaseData(user: User, resource: "accounts"): Promise<CoinbaseAccount[]>;
  private async fetchCoinbaseData(user: User, resource: "transactions"): Promise<CoinbaseTransaction[]>;
  private async fetchCoinbaseData<T>(user: User, resource: "accounts" | "transactions"): Promise<T[]> {
    await this.rateLimit(user).incrementOrError();
    if (!(await this.isAvailable(user))) throw new BadRequestException("Coinbase API credentials missing for user.");
    const results: T[] = [];
    let startingAfter: string | undefined;
    try {
      do {
        const query = startingAfter ? `?limit=100&starting_after=${startingAfter}` : `?limit=100`;
        const path = `/v2/${resource}`;
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
        startingAfter = response.data.pagination?.next_starting_after || null;
      } while (startingAfter);

      return results;
    } catch (err) {
      this.logger.error(`Failed to fetch Coinbase ${resource}`, err);
      return [];
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
