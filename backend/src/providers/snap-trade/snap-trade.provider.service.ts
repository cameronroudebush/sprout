import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountSubType } from "@backend/account/model/account.sub.type";
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
import { merge } from "lodash";
import { AccountPosition, AccountUniversalActivity, CommercialApiKeyAuth, Snaptrade, SnaptradeAuth } from "snaptrade-typescript-sdk";
import { FindOptionsWhere } from "typeorm";
import { ProviderBase } from "../base/core";
import { ProviderRateLimit } from "../base/rate-limit";

/**
 * Provider service adding automated account syncing and linking via SnapTrade.
 */
@Injectable()
export class SnapTradeProviderService extends ProviderBase {
  private readonly logger = new Logger("provider:snapTrade:service");
  public readonly snaptrade!: Snaptrade<CommercialApiKeyAuth>;

  constructor() {
    super();
    if (Configuration.providers.snapTrade.clientId && Configuration.providers.snapTrade.consumerKey) {
      this.logger.log("SnapTrade is configured. Initializing client.");
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

  /** Throws if SnapTrade SDK client is uninitialized */
  private checkClient() {
    if (this.snaptrade == null) throw new InternalServerErrorException("SnapTrade is not properly configured.");
  }

  /**
   * Main sync route called by background sync jobs.
   * Runs sequentially across institution assets to prevent 429 rate limit issues.
   */
  override async get(user: User, accountsOnly: boolean, institutionId?: string) {
    this.checkClient();
    const where: FindOptionsWhere<SnapTradeInstitutionAsset> = { institution: { user: { id: user.id } } };
    if (institutionId) where.institution = { id: institutionId, user: { id: user.id } };

    const assets = await SnapTradeInstitutionAsset.find({ where, relations: { institution: true } });
    const snapTradeUser = await SnapTradeUser.findOne({ where: { user: { id: user.id } } });
    if (!snapTradeUser) return [];

    const results: Awaited<ReturnType<SnapTradeProviderService["syncSingleInstitution"]>> = [];
    for (const asset of assets) {
      const updates = await this.syncSingleInstitution(user, snapTradeUser, asset, accountsOnly);
      results.push(...updates);
    }
    return results;
  }

  /** Syncs a single SnapTrade Institution Asset */
  private async syncSingleInstitution(user: User, snapTradeUser: SnapTradeUser, asset: SnapTradeInstitutionAsset, accountsOnly: boolean) {
    const results = [];
    try {
      await this.rateLimit(user).incrementOrError();
      const accountsRes = await this.snaptrade.accountInformation.listUserAccounts({
        userId: user.id,
        userSecret: snapTradeUser.userSecret,
      });

      // Filter accounts belonging specifically to this authorization ID
      const connAccounts = accountsRes.data.filter((acc) => acc.brokerage_authorization === asset.authorizationId);

      const startDate = format(subDays(new Date(), Configuration.providers.lookBackDays || 30), "yyyy-MM-dd");
      const endDate = format(new Date(), "yyyy-MM-dd");

      for (const rawAccount of connAccounts) {
        await this.rateLimit(user).incrementOrError();
        const balanceRes = await this.snaptrade.accountInformation.getUserAccountBalance({
          userId: user.id,
          userSecret: snapTradeUser.userSecret,
          accountId: rawAccount.id,
        });

        let account = this.convertSnapTradeAccount(rawAccount, balanceRes.data, user, asset.institution);
        let snapAsset = await SnapTradeAsset.findOne({
          where: { snapTradeAccountId: rawAccount.id, account: { user: { id: user.id } } },
          relations: { account: true },
        });

        if (snapAsset == null) {
          account = await account.insert();
          snapAsset = await new SnapTradeAsset(account, rawAccount.id).insert();
        } else {
          account = merge(snapAsset.account, account);
        }

        let positions: AccountPosition[] = [];
        let activities: AccountUniversalActivity[] = [];

        if (!accountsOnly) {
          try {
            await this.rateLimit(user).incrementOrError();
            const positionsRes = await this.snaptrade.accountInformation.getAllAccountPositions({
              userId: user.id,
              userSecret: snapTradeUser.userSecret,
              accountId: rawAccount.id,
            });
            positions = positionsRes.data.results || [];
          } catch (e) {
            this.logger.warn(`Failed to fetch positions for account ${rawAccount.id}`);
          }

          try {
            await this.rateLimit(user).incrementOrError();
            const activitiesRes = await this.snaptrade.accountInformation.getAccountActivities({
              userId: user.id,
              userSecret: snapTradeUser.userSecret,
              accountId: rawAccount.id,
              startDate,
              endDate,
            });
            activities = activitiesRes.data.data || [];
          } catch (e) {
            this.logger.warn(`Failed to fetch activities for account ${rawAccount.id}`);
          }
        }

        const holdings = positions.length > 0 ? this.convertSnapTradeHoldings(positions, account) : undefined;
        const transactions = await this.convertSnapTradeTransactions(activities, account, user);

        results.push({
          account,
          holdings,
          transactions,
          removedTransactionIds: [],
        });

        asset.institution.hasError = false;
        await asset.institution.update();
      }
    } catch (e) {
      this.logger.error(`Error syncing SnapTrade institution asset ${asset.id}:`, e);
      const err = e as AxiosError;
      if (err.response?.status === 401 || err.response?.status === 403) {
        asset.institution.hasError = true;
        await asset.institution.update();
      }
    }

    return results;
  }

  /** Generates redirect link token to initialize SnapTrade OAuth flow. */
  async generateLinkToken(user: User, redirectUrl?: string) {
    this.checkClient();

    let snapTradeUser = await SnapTradeUser.findOne({ where: { user: { id: user.id } } });
    if (!snapTradeUser) {
      try {
        const registerResponse = await this.snaptrade.authentication.registerSnapTradeUser({ userId: user.id });
        if (!registerResponse.data.userSecret) throw new Error("Invalid user secret returned");
        snapTradeUser = await new SnapTradeUser(user, registerResponse.data.userSecret).insert();
      } catch (e) {
        throw new BadRequestException("Failed to register SnapTrade user.");
      }
    }

    try {
      const loginData = await this.snaptrade.authentication.loginSnapTradeUser({
        userId: user.id,
        userSecret: snapTradeUser.userSecret,
        immediateRedirect: true,
        customRedirect: redirectUrl,
      });
      return (loginData.data as any).redirectURI as string;
    } catch (error) {
      this.logger.error("Could not initialize SnapTrade Login:", error);
      throw new InternalServerErrorException("Could not initialize SnapTrade linking flow.");
    }
  }

  /**
   * Exchanges/fetches newly linked accounts after user completes the connection popup.
   * Creates or merges Institutions, Accounts, Assets, and fetches Holdings handling rollbacks on failure.
   */
  async exchangeAndCreateAccounts(user: User) {
    this.checkClient();
    const snapTradeUser = await SnapTradeUser.findOne({ where: { user: { id: user.id } } });
    if (!snapTradeUser) throw new BadRequestException("SnapTrade user not registered");

    const userId = user.id;
    const userSecret = snapTradeUser.userSecret;

    const newAuthIds: string[] = [];

    try {
      await this.rateLimit(user).incrementOrError();
      const connections = (await this.snaptrade.connections.listBrokerageAuthorizations({ userId, userSecret })).data;
      const accountsRes = await this.snaptrade.accountInformation.listUserAccounts({ userId, userSecret });
      const allAccounts = accountsRes.data;

      const results: { account: Account; holdings?: Holding[]; transactions: Transaction[]; removedTransactionIds: string[] }[] = [];

      for (const conn of connections) {
        newAuthIds.push(conn.id!);
        const instName = conn.brokerage?.name || "SnapTrade Brokerage";
        let institution = await Institution.findOne({ where: { user: { id: user.id }, name: instName } });

        if (!institution) {
          institution = await new Institution(conn.brokerage?.url || this.config.url, instName, false, user).insert();
        }

        let instAsset = await SnapTradeInstitutionAsset.findOne({ where: { institution: { id: institution.id } } });
        if (!instAsset) {
          instAsset = await new SnapTradeInstitutionAsset(institution, conn.id!).insert();
        } else if (instAsset.authorizationId !== conn.id) {
          instAsset.authorizationId = conn.id!;
          await instAsset.update();
        }

        institution.hasError = false;
        await institution.update();

        const connAccounts = allAccounts.filter((acc) => acc.brokerage_authorization === conn.id);

        for (const rawAccount of connAccounts) {
          await this.rateLimit(user).incrementOrError();
          const balanceRes = await this.snaptrade.accountInformation.getUserAccountBalance({
            userId,
            userSecret,
            accountId: rawAccount.id,
          });

          let snapAsset = await SnapTradeAsset.findOne({
            where: { snapTradeAccountId: rawAccount.id, account: { user: { id: user.id } } },
            relations: { account: true },
          });

          if (!snapAsset) {
            const possibleExistingAccount = await Account.findOne({
              where: {
                user: { id: user.id },
                institution: { id: institution.id },
                name: rawAccount.name || rawAccount.number,
              },
            });

            if (possibleExistingAccount) {
              snapAsset = await SnapTradeAsset.findOne({
                where: { account: { id: possibleExistingAccount.id } },
                relations: { account: true },
              });

              if (snapAsset) {
                snapAsset.snapTradeAccountId = rawAccount.id;
                await snapAsset.update();
              } else {
                snapAsset = await new SnapTradeAsset(possibleExistingAccount, rawAccount.id).insert();
                snapAsset.account = possibleExistingAccount;
              }
            }
          }

          let finalAccount: Account;
          if (!snapAsset) {
            const newAccount = this.convertSnapTradeAccount(rawAccount, balanceRes.data, user, institution);
            finalAccount = await newAccount.insert();
            await AccountHistory.insertForNewAccount(finalAccount);
            await new SnapTradeAsset(finalAccount, rawAccount.id).insert();
          } else {
            const accountToUpdate = this.convertSnapTradeAccount(rawAccount, balanceRes.data, user, institution);
            finalAccount = merge(snapAsset.account, accountToUpdate);
            await finalAccount.update();
            await AccountHistory.insertForAccount(finalAccount);
          }

          // Fetch Holdings for the newly created or merged account
          let positions: AccountPosition[] = [];
          try {
            await this.rateLimit(user).incrementOrError();
            const positionsRes = await this.snaptrade.accountInformation.getAllAccountPositions({
              userId,
              userSecret,
              accountId: rawAccount.id,
            });
            positions = positionsRes.data.results || [];
          } catch (e) {
            this.logger.warn(`Failed to fetch positions for account ${rawAccount.id}`);
          }

          const holdings = positions.length > 0 ? this.convertSnapTradeHoldings(positions, finalAccount) : undefined;

          if (holdings && holdings.length > 0) {
            // Remove old holdings before saving the new snapshot to avoid duplicates on re-link
            await Holding.delete({ account: { id: finalAccount.id } });
            await Promise.all(holdings.map((h) => h.insert()));
          }

          results.push({
            account: finalAccount,
            holdings,
            transactions: [],
            removedTransactionIds: [],
          });
        }
      }

      return results;
    } catch (error) {
      this.logger.error("Error creating SnapTrade accounts, rolling back newly created authorizations...", error);
      for (const authId of newAuthIds) {
        try {
          await this.snaptrade.connections.removeBrokerageAuthorization({ authorizationId: authId, userId, userSecret });
        } catch (e) {
          this.logger.warn(`Failed to clean up orphaned SnapTrade authorization ${authId}`);
        }
      }
      throw new InternalServerErrorException(`Failed to link SnapTrade accounts: ${error}`);
    }
  }

  /** Removes a SnapTrade brokerage connection from remote servers to stop billing. */
  async unlinkInstitution(user: User, institutionId: string) {
    this.checkClient();
    const instAsset = await SnapTradeInstitutionAsset.findOne({
      where: { institution: { id: institutionId, user: { id: user.id } } },
      relations: { institution: true },
    });

    if (!instAsset) return true;

    const snapTradeUser = await SnapTradeUser.findOne({ where: { user: { id: user.id } } });
    if (!snapTradeUser) return true;

    this.logger.log(`Removing SnapTrade connection for: ${instAsset.institution.name}`);
    try {
      await this.rateLimit(user).incrementOrError();
      await this.snaptrade.connections.removeBrokerageAuthorization({
        authorizationId: instAsset.authorizationId,
        userId: user.id,
        userSecret: snapTradeUser.userSecret,
      });
      return true;
    } catch (error) {
      this.logger.error("Failed to unlink SnapTrade institution", error);
      return false;
    }
  }

  /** Converts a raw SnapTrade account payload into Sprout's local Account entity without inserting. */
  private convertSnapTradeAccount(rawAccount: any, balanceData: any, user: User, institution: Institution) {
    const balanceObj = Array.isArray(balanceData) ? balanceData[0] : balanceData;
    const balance = parseFloat(`${balanceObj?.cash || 0}`);
    const availableBalance = parseFloat(`${balanceObj?.buying_power ?? balance}`);

    const accType = AccountType.investment; // SnapTrade only provides investment info
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
      this.mapSubType(rawAccount.raw_type),
    );
  }

  /** Converts SnapTrade positions into Sprout Holdings */
  private convertSnapTradeHoldings(positions: AccountPosition[], account: Account) {
    return positions.map((pos) => {
      const shares = parseFloat(`${pos.units}`) || 0;
      const purchasePrice = pos["average_purchase_price"] || 0;
      const currentPrice = parseFloat(`${pos.price}`) || 0;

      const symbolString = pos["symbol"]?.symbol || "UNKNOWN";
      const description = pos["symbol"]?.description || pos["symbol"]?.symbol || "Holding";

      return new Holding(
        (pos.currency as any)?.code || account.currency,
        purchasePrice * shares,
        description,
        currentPrice * shares,
        purchasePrice,
        shares,
        symbolString,
        account,
      );
    });
  }

  /** Converts SnapTrade activities into Sprout Transactions */
  private async convertSnapTradeTransactions(activities: AccountUniversalActivity[], account: Account, user: User) {
    const now = new Date();

    return await Promise.all(
      activities.map(async (t) => {
        const category = await Category.getOrCreate(t.type || "Investment", user);
        const parsedDate = t.trade_date || t.settlement_date ? parseISO(t.trade_date! || t.settlement_date!) : new Date();

        const transactionDate = isToday(parsedDate)
          ? set(parsedDate, {
              hours: now.getHours(),
              minutes: now.getMinutes(),
              seconds: now.getSeconds(),
              milliseconds: now.getMilliseconds(),
            })
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
  }

  /** Maps raw SnapTrade types to Sprout AccountSubType */
  private mapSubType(type: string | undefined | null): AccountSubType | undefined {
    switch (type) {
      case "Individual":
      case "Margin":
        return AccountSubType.brokerage;
      case "IRA":
      case "Roth IRA":
        return AccountSubType.ira;
      case "401k":
        return AccountSubType["401k"];
      case "Checking":
        return AccountSubType.checking;
      case "Savings":
        return AccountSubType.savings;
      default:
        return undefined;
    }
  }
}
