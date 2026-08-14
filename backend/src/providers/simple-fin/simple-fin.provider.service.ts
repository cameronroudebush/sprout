import { Account } from "@backend/account/model/account.model";
import { Category } from "@backend/category/model/category.model";
import { Configuration } from "@backend/config/core";
import { Holding } from "@backend/holding/model/holding.model";
import { Institution } from "@backend/institution/model/institution.model";
import { ProviderConfig } from "@backend/providers/base/model/provider.config.model";
import { ProviderSubType, ProviderType } from "@backend/providers/base/provider.type";
import { SimpleFINReturn } from "@backend/providers/simple-fin/return.type";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { BadRequestException, Injectable, Logger, NotImplementedException } from "@nestjs/common";
import { subDays } from "date-fns";
import { ExchangeInstitution, ProviderBase, ProviderSyncResult } from "../base/core";
import { ProviderRateLimit } from "../base/rate-limit";

@Injectable()
export class SimpleFINProviderService extends ProviderBase<void, void, string[], string, SimpleFINReturn.Account, undefined, { account: Account }> {
  protected readonly logger = new Logger("provider:simpleFin:service");

  override getAppConfiguration = () => Configuration.providers.simpleFIN;
  config = new ProviderConfig(
    "SimpleFIN",
    ProviderType.simpleFin,
    ProviderSubType.bankingInvestments,
    "https://www.simplefin.org/",
    "https://beta-bridge.simplefin.org/my-account",
  );
  override rateLimit = (user?: User) => new ProviderRateLimit(ProviderType.simpleFin, Configuration.providers.simpleFIN.rateLimit, user);
  override isAvailable = async (user: User) => !!user.config.simpleFinToken;

  override async generateLinkToken(): Promise<void> {
    throw new NotImplementedException("SimpleFIN linking is manual via setup tokens.");
  }

  /**
   * Public utility specifically for UserService to convert a pasted setup token
   * into a permanent access token before saving it to the database.
   */
  public async convertSetupToken(setupToken: string): Promise<string> {
    const claimUrl = Buffer.from(setupToken, "base64").toString("utf-8");
    try {
      new URL(claimUrl);
    } catch (e) {
      throw new BadRequestException("Failed to parse claimUrl. Are you sure you only included the 'setup token'?");
    }

    const claimResponse = await fetch(claimUrl, { method: "POST", headers: { "Content-Length": "0" } });
    if (!claimResponse.ok) throw new Error("Failed to exchange SimpleFIN token.");

    return await claimResponse.text();
  }

  /**
   * Previews accounts available on the user's token that have not been linked to Sprout yet.
   */
  async getUnlinkedAccounts(user: User): Promise<Account[]> {
    if (!user.config.simpleFinToken) return [];

    const existingAccounts = await Account.find({ where: { user: { id: user.id }, provider: ProviderType.simpleFin } });
    const existingIds = existingAccounts.map((a) => a.id);

    const data = await this.fetchData(user.config.simpleFinToken, true, user);
    const unlinked = data.accounts.filter((raw) => !existingIds.includes(raw.id));

    return unlinked.map((raw) => {
      const balance = parseFloat(raw.balance);
      const institution = new Institution(raw.org.url, raw.org.name, false, user);
      institution.id = crypto.randomUUID(); // Temp ID for frontend rendering

      return Account.fromPlain({
        id: raw.id,
        name: raw.name,
        type: this.determineAccountType(raw.name, balance, raw.holdings?.length > 0),
        subType: this.determineAccountSubType(raw.name),
        currency: raw.currency,
        provider: ProviderType.simpleFin,
        balance,
        availableBalance: parseFloat(raw["available-balance"]),
        institution,
      });
    });
  }

  protected async performExchange(user: User, accountIdsToLink: string[]): Promise<ExchangeInstitution<string, SimpleFINReturn.Account>[]> {
    const accessToken = user.config.simpleFinToken;
    if (!accessToken) throw new BadRequestException("SimpleFIN token not configured");

    const data = await this.fetchData(accessToken, false, user);
    const selectedAccounts = data.accounts.filter((acc) => accountIdsToLink.includes(acc.id));

    const institutionsMap = new Map<string, SimpleFINReturn.Account[]>();
    selectedAccounts.forEach((acc) => {
      if (!institutionsMap.has(acc.org.name)) institutionsMap.set(acc.org.name, []);
      institutionsMap.get(acc.org.name)!.push(acc);
    });

    return Array.from(institutionsMap.entries()).map(([name, accounts]) => ({
      institutionName: name,
      institutionUrl: accounts[0]?.org.url || this.config.url,
      authContext: accessToken,
      rawAccounts: accounts,
    }));
  }

  protected async rollbackExchange(): Promise<void> {}

  protected async performSync(user: User, _asset: undefined, accountsOnly: boolean): Promise<ProviderSyncResult[]> {
    if (!user.config.simpleFinToken) return [];

    const data = await this.fetchData(user.config.simpleFinToken, accountsOnly, user);
    const existingAccounts = await Account.find({ where: { user: { id: user.id }, provider: ProviderType.simpleFin } });
    const existingIds = existingAccounts.map((a) => a.id);

    const results: ProviderSyncResult[] = [];

    for (const rawAccount of data.accounts) {
      if (!existingIds.includes(rawAccount.id)) continue;

      let institution = await Institution.findOne({ where: { user: { id: user.id }, name: rawAccount.org.name } });
      if (!institution) institution = await new Institution(rawAccount.org.url, rawAccount.org.name, false, user).insert();

      const finalAccount = await this.mapToSproutAccount(rawAccount, user.config.simpleFinToken, user, institution);

      const syncData = accountsOnly
        ? { holdings: undefined, transactions: undefined, removedTransactionIds: [] }
        : await this.fetchInitialSyncData(rawAccount, finalAccount, user.config.simpleFinToken, user);

      results.push({ account: finalAccount, ...syncData });
    }
    return results;
  }

  protected async performUnlink(): Promise<void> {
    /* SimpleFIN tokens are managed locally */
  }
  protected async handleSyncError(): Promise<void> {}
  protected async setInstitutionError(): Promise<void> {}

  protected extractProviderAccountId(rawAccount: SimpleFINReturn.Account): string {
    return rawAccount.id;
  }
  protected extractAccountName(rawAccount: SimpleFINReturn.Account): string {
    return rawAccount.name;
  }

  protected async mapToSproutAccount(
    rawAccount: SimpleFINReturn.Account,
    _authContext: string | undefined,
    user: User,
    institution: Institution,
  ): Promise<Account> {
    const balance = parseFloat(rawAccount.balance);
    const availableBalance = parseFloat(rawAccount["available-balance"]);

    const acc = new Account(
      rawAccount.name,
      ProviderType.simpleFin,
      user,
      institution,
      balance,
      availableBalance,
      this.determineAccountType(rawAccount.name, balance, rawAccount.holdings?.length > 0),
      rawAccount.currency,
      this.determineAccountSubType(rawAccount.name),
    );
    // Explicitly set the ID to match SimpleFIN to prevent random UUID generation during insert
    acc.id = rawAccount.id;
    acc.extra = rawAccount.extra;
    return acc;
  }

  protected async fetchInitialSyncData(
    rawAccount: SimpleFINReturn.Account,
    account: Account,
    _authContext: string,
    user: User,
  ): Promise<Omit<ProviderSyncResult, "account">> {
    const holdings = rawAccount.holdings?.map((hold) => {
      const h = new Holding(
        hold.currency,
        parseFloat(hold.cost_basis),
        hold.description,
        parseFloat(hold.market_value),
        parseFloat(hold.purchase_price),
        parseFloat(hold.shares),
        hold.symbol,
        account,
      );
      h.id = hold.id;
      return h;
    });

    const transactions = await Promise.all(
      (rawAccount.transactions || []).map(async (t) => {
        const category = await Category.getOrCreate(t.extra?.category, user);
        const newTransaction = new Transaction(parseFloat(t.amount), new Date(t.posted * 1000), t.description, undefined, t.pending ?? false, account);
        newTransaction.id = t.id;
        newTransaction.category = category;
        newTransaction.extra = t.extra;
        return newTransaction;
      }),
    );

    return { transactions, removedTransactionIds: [], holdings };
  }

  protected async getInstitutionAssetsForUser(): Promise<undefined[]> {
    return [undefined];
  }
  protected async upsertInstitutionAsset(): Promise<void> {}

  protected async getAccountAsset(providerAccountId: string, userId: string): Promise<{ account: Account } | null> {
    const account = await Account.findOne({ where: { id: providerAccountId, user: { id: userId } } });
    return account ? { account } : null;
  }

  protected async getAccountAssetByAccountId(accountId: string): Promise<{ account: Account } | null> {
    const account = await Account.findOne({ where: { id: accountId } });
    return account ? { account } : null;
  }

  protected async createAccountAsset(account: Account, _providerAccountId: string): Promise<{ account: Account }> {
    return { account };
  }

  protected async updateAccountAsset(): Promise<void> {}

  /**
   * Fetches data from SimpleFIN via rest requests
   *
   * @param balancesOnly If we don't want transactional data. Default is false so we do want transactional data.
   */
  private async fetchData(accessToken: string, balancesOnly: boolean, user: User): Promise<SimpleFINReturn.FinancialData> {
    const startDateEpoch = Math.round(subDays(new Date(), Configuration.providers.lookBackDays).getTime() / 1000);
    const url = `${accessToken}/accounts?pending=1&start-date=${startDateEpoch}&balances-only=${balancesOnly ? 1 : 0}`;
    const [username, pass] = url.replace("https://", "").split("@")[0]!.split(":");
    const cleanURL = url.replace(username!, "").replace(pass!, "").replace(":@", "");

    await this.rateLimit(user).incrementOrError();
    const result = await fetch(cleanURL, { method: "GET", headers: { Authorization: "Basic " + btoa(`${username}:${pass}`) } });
    return (await result.json()) as SimpleFINReturn.FinancialData;
  }
}
