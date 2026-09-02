import { Account } from "@backend/account/model/account.model";
import { Configuration } from "@backend/config/core";
import { Holding } from "@backend/holding/model/holding.model";
import { Institution } from "@backend/institution/model/institution.model";
import { ExchangeInstitution, ProviderBase, ProviderSyncResult } from "@backend/providers/base/core";
import { ProviderConfig } from "@backend/providers/base/model/provider.config.model";
import { ProviderSubType, ProviderType } from "@backend/providers/base/provider.type";
import { ProviderRateLimit } from "@backend/providers/base/rate-limit";
import { SimpleFINReturn } from "@backend/providers/simple-fin/return.type";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { BadRequestException, Injectable, Logger, NotImplementedException } from "@nestjs/common";
import { subDays } from "date-fns";

@Injectable()
export class SimpleFINProviderService extends ProviderBase<void, void, string[], string, SimpleFINReturn.Account, undefined> {
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

  override async getUnlinkedAccounts(user: User): Promise<Account[]> {
    if (!user.config.simpleFinToken) return [];
    const existingAccounts = await Account.find({ where: { user: { id: user.id }, provider: ProviderType.simpleFin } });
    const existingProviderAccountIds = existingAccounts.map((a) => a.providerAccountId).filter(Boolean);
    const data = await this.fetchData(user.config.simpleFinToken, true, user);
    const unlinked = data.accounts.filter((raw) => !existingProviderAccountIds.includes(raw.id));
    return await Promise.all(
      unlinked.map(async (raw) => {
        const institution = new Institution(raw.org.url, raw.org.name, false, user);
        institution.id = crypto.randomUUID();
        const account = await this.mapToSproutAccount(raw, user.config.simpleFinToken, user, institution);
        account.id = raw.id;
        return account;
      }),
    );
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

  protected async performSync(user: User, _asset: undefined, accountsOnly: boolean): Promise<ProviderSyncResult[]> {
    if (!user.config.simpleFinToken) return [];

    const data = await this.fetchData(user.config.simpleFinToken, accountsOnly, user);
    const existingAccounts = await Account.find({ where: { user: { id: user.id }, provider: ProviderType.simpleFin } });
    const existingMap = new Map(existingAccounts.map((a) => [a.providerAccountId, a]));

    const results: ProviderSyncResult[] = [];

    for (const rawAccount of data.accounts) {
      if (!existingMap.has(rawAccount.id)) continue;

      const existingAccount = existingMap.get(rawAccount.id)!;
      const hasError = data.errors?.some((x) => x.includes(rawAccount.org.name)) ?? false;
      const institution = existingAccount.institution || new Institution(rawAccount.org.url, rawAccount.org.name, hasError, user);

      const updatedAccount = await this.mapToSproutAccount(rawAccount, user.config.simpleFinToken, user, institution);

      existingAccount.balance = updatedAccount.balance;
      existingAccount.availableBalance = updatedAccount.availableBalance;
      existingAccount.extra = updatedAccount.extra;

      const syncData = accountsOnly
        ? { holdings: undefined, transactions: undefined, removedTransactionIds: [] }
        : await this.fetchInitialSyncData(rawAccount, existingAccount, user.config.simpleFinToken, user);

      results.push({
        account: existingAccount,
        ...syncData,
      });
    }
    return results;
  }

  protected override extractProviderAccountId(rawAccount: SimpleFINReturn.Account): string {
    return rawAccount.id;
  }
  protected override extractAccountName(rawAccount: SimpleFINReturn.Account): string {
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
      rawAccount.id,
      user,
      institution,
      balance,
      availableBalance,
      this.determineAccountType(rawAccount.name, balance, rawAccount.holdings?.length > 0),
      rawAccount.currency,
      this.determineAccountSubType(rawAccount.name),
    );
    acc.extra = rawAccount.extra;
    return acc;
  }

  protected override async fetchInitialSyncData(
    rawAccount: SimpleFINReturn.Account,
    account: Account,
    _authContext: string,
    _user: User,
  ): Promise<Omit<ProviderSyncResult, "account">> {
    const holdings = rawAccount.holdings?.map((hold) => {
      return new Holding(
        hold.currency,
        parseFloat(hold.cost_basis),
        hold.description,
        parseFloat(hold.market_value),
        parseFloat(hold.purchase_price),
        parseFloat(hold.shares),
        hold.symbol,
        account,
      );
    });

    const transactions = await Promise.all(
      (rawAccount.transactions || []).map(async (t) => {
        const newTransaction = new Transaction(parseFloat(t.amount), new Date(t.posted * 1000), t.description, undefined, t.pending ?? false, account);
        newTransaction.providerId = t.id;
        newTransaction.extra = t.extra;
        return newTransaction;
      }),
    );

    return { transactions, removedTransactionIds: [], holdings };
  }

  protected async getInstitutionAssetsForUser(): Promise<undefined[]> {
    return [undefined]; // Force the sync loop to fire
  }

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
