import { Account } from "@backend/account/model/account.model";
import { AccountType, AccountTypeIsLiability } from "@backend/account/model/account.type";
import { Category } from "@backend/category/model/category.model";
import { Configuration } from "@backend/config/core";
import { Holding } from "@backend/holding/model/holding.model";
import { Institution } from "@backend/institution/model/institution.model";
import { ProviderConfig } from "@backend/providers/base/model/provider.config.model";
import { ProviderSubType, ProviderType } from "@backend/providers/base/provider.type";
import { SnapTradeAsset } from "@backend/providers/snap-trade/model/snap-trade.asset.model";
import { SnapTradeInstitutionAsset } from "@backend/providers/snap-trade/model/snap-trade.institution.asset.model";
import { SnapTradeUser } from "@backend/providers/snap-trade/model/snap-trade.user";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { BadRequestException, Injectable, InternalServerErrorException, Logger } from "@nestjs/common";
import { AxiosError } from "axios";
import { format, isToday, parseISO, set, subDays } from "date-fns";
import { AccountPosition, AccountUniversalActivity, CommercialApiKeyAuth, Snaptrade, SnaptradeAuth } from "snaptrade-typescript-sdk";
import { FindOptionsWhere } from "typeorm";
import { ExchangeInstitution, ProviderBase, ProviderSyncResult } from "../base/core";
import { ProviderRateLimit } from "../base/rate-limit";

export interface SnapTradeLinkOptions {
  redirectUrl?: string;
}

export interface SnapTradeAuthContext {
  authorizationId: string;
  userSecret: string;
}

@Injectable()
export class SnapTradeProviderService extends ProviderBase<
  SnapTradeLinkOptions,
  string,
  void,
  SnapTradeAuthContext,
  any,
  SnapTradeInstitutionAsset,
  SnapTradeAsset
> {
  protected readonly logger = new Logger("provider:snapTrade:service");
  public readonly snaptrade!: Snaptrade<CommercialApiKeyAuth>;

  constructor() {
    super();
    if (Configuration.providers.snapTrade.clientId && Configuration.providers.snapTrade.consumerKey) {
      this.snaptrade = new Snaptrade({
        auth: SnaptradeAuth.commercialApiKey({
          clientId: Configuration.providers.snapTrade.clientId,
          consumerKey: Configuration.providers.snapTrade.consumerKey,
        }),
      });
    }
  }

  override getAppConfiguration = () => Configuration.providers.snapTrade;
  config = new ProviderConfig("SnapTrade", ProviderType.snapTrade, ProviderSubType.bankingInvestments, "https://snaptrade.com/");
  override rateLimit = (user?: User) => new ProviderRateLimit(ProviderType.snapTrade, Configuration.providers.snapTrade.rateLimit, user);

  override isAvailable = async (_user: User) => {
    try {
      if (!this.snaptrade) return false;
      const status = await this.snaptrade.apiStatus.check();
      return status.data.online ?? false;
    } catch (e) {
      return false;
    }
  };

  private checkClient() {
    if (this.snaptrade == null) throw new InternalServerErrorException("SnapTrade is not properly configured.");
  }

  override async generateLinkToken(user: User, options?: SnapTradeLinkOptions): Promise<string> {
    this.checkClient();
    let snapTradeUser = await SnapTradeUser.findOne({ where: { user: { id: user.id } } });
    if (!snapTradeUser) {
      try {
        const res = await this.snaptrade.authentication.registerSnapTradeUser({ userId: user.id });
        if (!res.data.userSecret) throw new Error("Invalid user secret");
        snapTradeUser = await new SnapTradeUser(user, res.data.userSecret).insert();
      } catch (e) {
        throw new BadRequestException("Failed to register SnapTrade user.");
      }
    }

    const loginData = await this.snaptrade.authentication.loginSnapTradeUser({
      userId: user.id,
      userSecret: snapTradeUser.userSecret,
      immediateRedirect: true,
      customRedirect: options?.redirectUrl,
    });
    return (loginData.data as any).redirectURI as string;
  }

  protected async performExchange(user: User, _payload: void): Promise<ExchangeInstitution<SnapTradeAuthContext, any>[]> {
    this.checkClient();
    const snapTradeUser = await SnapTradeUser.findOne({ where: { user: { id: user.id } } });
    if (!snapTradeUser) throw new BadRequestException("SnapTrade user not registered");

    await this.rateLimit(user).incrementOrError();
    const connections = (await this.snaptrade.connections.listBrokerageAuthorizations({ userId: user.id, userSecret: snapTradeUser.userSecret })).data;
    const allAccounts = (await this.snaptrade.accountInformation.listUserAccounts({ userId: user.id, userSecret: snapTradeUser.userSecret })).data;

    return connections.map((conn) => ({
      institutionName: conn.brokerage?.name || "SnapTrade Brokerage",
      institutionUrl: conn.brokerage?.url || this.config.url,
      authContext: { authorizationId: conn.id!, userSecret: snapTradeUser.userSecret },
      rawAccounts: allAccounts.filter((acc) => acc.brokerage_authorization === conn.id),
    }));
  }

  protected async rollbackExchange(user: User, _payload: void, authContext: SnapTradeAuthContext): Promise<void> {
    try {
      await this.snaptrade.connections.removeBrokerageAuthorization({
        authorizationId: authContext.authorizationId,
        userId: user.id,
        userSecret: authContext.userSecret,
      });
    } catch (e) {}
  }

  protected async performSync(user: User, asset: SnapTradeInstitutionAsset, accountsOnly: boolean): Promise<ProviderSyncResult[]> {
    const snapTradeUser = await SnapTradeUser.findOne({ where: { user: { id: user.id } } });
    if (!snapTradeUser) return [];

    await this.rateLimit(user).incrementOrError();
    const allAccounts = (await this.snaptrade.accountInformation.listUserAccounts({ userId: user.id, userSecret: snapTradeUser.userSecret })).data;
    const connAccounts = allAccounts.filter((acc) => acc.brokerage_authorization === asset.authorizationId);

    const results: ProviderSyncResult[] = [];
    for (const rawAccount of connAccounts) {
      let finalAccount = await this.mapToSproutAccount(
        rawAccount,
        { authorizationId: asset.authorizationId, userSecret: snapTradeUser.userSecret },
        user,
        asset.institution,
      );
      let providerAsset = await SnapTradeAsset.findOne({
        where: { snapTradeAccountId: rawAccount.id, account: { user: { id: user.id } } },
        relations: { account: true },
      });

      // SnapTrade auto-links new accounts, so we insert them if they appear on an existing connection
      if (providerAsset == null) {
        finalAccount = await finalAccount.insert();
        await new SnapTradeAsset(finalAccount, rawAccount.id).insert();
      } else {
        const updatedBalance = finalAccount.balance;
        const updatedAvail = finalAccount.availableBalance;

        finalAccount = providerAsset.account;
        finalAccount.balance = updatedBalance;
        finalAccount.availableBalance = updatedAvail;
      }

      const syncData = accountsOnly
        ? { holdings: [], transactions: [], removedTransactionIds: [] }
        : await this.fetchInitialSyncData(rawAccount, finalAccount, { authorizationId: asset.authorizationId, userSecret: snapTradeUser.userSecret }, user);

      results.push({
        account: finalAccount,
        holdings: syncData.holdings,
        transactions: syncData.transactions,
        removedTransactionIds: syncData.removedTransactionIds,
      });
    }
    return results;
  }

  protected async performUnlink(user: User, asset: SnapTradeInstitutionAsset): Promise<void> {
    const snapTradeUser = await SnapTradeUser.findOne({ where: { user: { id: user.id } } });
    if (!snapTradeUser) return;
    await this.rateLimit(user).incrementOrError();
    await this.snaptrade.connections.removeBrokerageAuthorization({
      authorizationId: asset.authorizationId,
      userId: user.id,
      userSecret: snapTradeUser.userSecret,
    });
  }

  protected async handleSyncError(asset: SnapTradeInstitutionAsset, error: unknown): Promise<void> {
    const err = error as AxiosError;
    if (err.response?.status === 401 || err.response?.status === 403) {
      await this.setInstitutionError(asset, true);
    } else {
      this.logger.error(`Failed to sync SnapTrade for institution ${asset.institution.name}:`, error);
    }
  }

  protected async setInstitutionError(asset: SnapTradeInstitutionAsset, hasError: boolean): Promise<void> {
    asset.institution.hasError = hasError;
    await asset.institution.update();
  }

  protected extractProviderAccountId(rawAccount: any): string {
    return rawAccount.id;
  }
  protected extractAccountName(rawAccount: any): string {
    return rawAccount.name || rawAccount.number;
  }

  protected async mapToSproutAccount(rawAccount: any, authContext: SnapTradeAuthContext | undefined, user: User, institution: Institution): Promise<Account> {
    const balanceRes = await this.snaptrade.accountInformation.getUserAccountBalance({
      userId: user.id,
      userSecret: authContext!.userSecret,
      accountId: rawAccount.id,
    });
    const balanceObj = Array.isArray(balanceRes.data) ? balanceRes.data[0] : balanceRes.data;
    const availableBalance = parseFloat(`${balanceObj?.cash || 0}`);
    const balance = rawAccount.balance.total.amount;
    const accType = AccountType.investment;
    const isLiability = AccountTypeIsLiability(accType);

    return new Account(
      rawAccount.name || rawAccount.number || "Brokerage Account",
      ProviderType.snapTrade,
      user,
      institution,
      balance * (isLiability ? -1 : 1),
      availableBalance * (isLiability ? -1 : 1),
      accType,
      rawAccount.balance?.total?.currency || "USD",
      this.determineAccountSubType(rawAccount.raw_type),
    );
  }

  protected async fetchInitialSyncData(
    rawAccount: any,
    account: Account,
    authContext: SnapTradeAuthContext,
    user: User,
  ): Promise<Omit<ProviderSyncResult, "account">> {
    const startDate = format(subDays(new Date(), Configuration.providers.lookBackDays || 30), "yyyy-MM-dd");
    const endDate = format(new Date(), "yyyy-MM-dd");

    let positions: AccountPosition[] = [];
    let activities: AccountUniversalActivity[] = [];

    try {
      positions =
        (await this.snaptrade.accountInformation.getAllAccountPositions({ userId: user.id, userSecret: authContext.userSecret, accountId: rawAccount.id })).data
          .results || [];
      activities =
        (
          await this.snaptrade.accountInformation.getAccountActivities({
            userId: user.id,
            userSecret: authContext.userSecret,
            accountId: rawAccount.id,
            startDate,
            endDate,
          })
        ).data.data || [];
    } catch (e) {}

    const holdings = positions.map((pos) => {
      const shares = parseFloat(`${pos.units}`) || 0;
      const price = parseFloat(`${pos.price}`) || 0;
      const costBasis = parseFloat(`${pos.cost_basis}`) || 0;
      const currency = pos.currency || account.currency;
      const holding = new Holding(
        currency,
        price * shares,
        pos.instrument.description,
        price * shares,
        costBasis * shares,
        shares,
        pos.instrument.symbol,
        account,
      );
      holding.description = pos.instrument.description;
      return holding;
    });

    const now = new Date();
    const transactions = await Promise.all(
      activities.map(async (t) => {
        const category = await Category.getOrCreate(t.type || "Investment", user);
        const parsedDate = t.trade_date || t.settlement_date ? parseISO(t.trade_date! || t.settlement_date!) : new Date();
        const transactionDate = isToday(parsedDate)
          ? set(parsedDate, { hours: now.getHours(), minutes: now.getMinutes(), seconds: now.getSeconds(), milliseconds: now.getMilliseconds() })
          : parsedDate;
        const newTransaction = new Transaction(
          (t.amount ?? 0) * -1,
          transactionDate,
          t.description || t.symbol?.symbol || t.type || "Activity",
          undefined,
          false,
          account,
        );
        newTransaction.id = t.id!;
        newTransaction.category = category;
        newTransaction.extra = t;
        return newTransaction;
      }),
    );

    return { transactions, removedTransactionIds: [], holdings };
  }

  protected async getInstitutionAssetsForUser(userId: string, institutionId?: string): Promise<SnapTradeInstitutionAsset[]> {
    const where: FindOptionsWhere<SnapTradeInstitutionAsset> = { institution: { user: { id: userId } } };
    if (institutionId) where.institution = { id: institutionId, user: { id: userId } };
    return await SnapTradeInstitutionAsset.find({ where, relations: { institution: true } });
  }

  protected async upsertInstitutionAsset(institution: Institution, authContext: SnapTradeAuthContext): Promise<void> {
    let instAsset = await SnapTradeInstitutionAsset.findOne({ where: { institution: { id: institution.id } } });
    if (!instAsset) {
      await new SnapTradeInstitutionAsset(institution, authContext.authorizationId).insert();
    } else {
      instAsset.authorizationId = authContext.authorizationId;
      await instAsset.update();
    }
  }

  protected async getAccountAsset(providerAccountId: string, userId: string): Promise<SnapTradeAsset | null> {
    return await SnapTradeAsset.findOne({ where: { snapTradeAccountId: providerAccountId, account: { user: { id: userId } } }, relations: { account: true } });
  }

  protected async getAccountAssetByAccountId(accountId: string): Promise<SnapTradeAsset | null> {
    return await SnapTradeAsset.findOne({ where: { account: { id: accountId } }, relations: { account: true } });
  }

  protected async createAccountAsset(account: Account, providerAccountId: string): Promise<SnapTradeAsset> {
    return await new SnapTradeAsset(account, providerAccountId).insert();
  }

  protected async updateAccountAsset(asset: SnapTradeAsset, providerAccountId: string): Promise<void> {
    asset.snapTradeAccountId = providerAccountId;
    await asset.update();
  }
}
