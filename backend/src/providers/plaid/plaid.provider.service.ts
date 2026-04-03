import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountSubType } from "@backend/account/model/account.sub.type";
import { AccountType } from "@backend/account/model/account.type";
import { Configuration } from "@backend/config/core";
import { Institution } from "@backend/institution/model/institution.model";
import { ProviderConfig } from "@backend/providers/base/model/provider.config.model";
import { ProviderType } from "@backend/providers/base/provider.type";
import { PlaidLinkDTO } from "@backend/providers/plaid/model/api/link.dto";
import { PlaidLinkTokenDTO } from "@backend/providers/plaid/model/api/link.token.dto";
import { PlaidAsset } from "@backend/providers/plaid/model/plaid.asset";
import { User } from "@backend/user/model/user.model";
import { Injectable, InternalServerErrorException, Logger } from "@nestjs/common";
import {
  CountryCode,
  AccountSubtype as PlaidAccountSubType,
  AccountType as PlaidAccountType,
  PlaidApi,
  Configuration as PlaidConfig,
  PlaidEnvironments,
  Products,
} from "plaid";
import { ProviderBase } from "../base/core";
import { ProviderRateLimit } from "../base/rate-limit";

/**
 * This provider adds account linking via plaid.
 */
@Injectable()
export class PlaidProviderService extends ProviderBase {
  override getAppConfiguration = () => Configuration.providers.plaid;
  private readonly logger = new Logger("provider:service:plaid");
  config = new ProviderConfig("Plaid", ProviderType.plaid, "https://plaid.com/", "https://plaid.com/assets/img/favicons/apple-touch-icon.png");
  override rateLimit = (user?: User) => new ProviderRateLimit(ProviderType.plaid, Configuration.providers.plaid.rateLimit, user);
  override isAvailable = async (_user: User) => !!Configuration.providers.plaid.secret && !!Configuration.providers.plaid.clientId;
  /** The client for talking with plaid for account info */
  private readonly plaidClient?: PlaidApi;

  constructor() {
    super();
    if (!!Configuration.providers.plaid.secret && !!Configuration.providers.plaid.clientId) {
      this.logger.log("Plaid is configured. Initializing client.");
      this.plaidClient = new PlaidApi(
        new PlaidConfig({
          // Always assume sandbox for development else use production
          basePath: Configuration.isDevBuild ? PlaidEnvironments["sandbox"] : PlaidEnvironments["production"],
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

  override async get(_user: User, _accountsOnly: boolean) {
    // TODO, background syncing
    return [];
  }

  /**
   * Generates a short-lived link_token to initialize Plaid Link on the mobile/web frontend.
   */
  async generateLinkToken(user: User) {
    if (this.plaidClient == null) throw new InternalServerErrorException("Plaid is not properly configured.");
    try {
      const response = await this.plaidClient.linkTokenCreate({
        user: { client_user_id: user.id },
        client_name: "Sprout",
        products: [Products.Transactions],
        country_codes: [CountryCode.Us],
        language: "en",
      });
      return new PlaidLinkTokenDTO(response.data.link_token);
    } catch (error) {
      throw new InternalServerErrorException("Could not initialize Plaid.");
    }
  }

  /**
   * Exchanges the public_token from the frontend for an access_token,
   * then fetches and saves the chosen accounts.
   */
  async exchangeAndCreateAccounts(user: User, dto: PlaidLinkDTO) {
    if (this.plaidClient == null) throw new InternalServerErrorException("Plaid is not properly configured.");
    const metadata = dto.metadata;
    try {
      // Exchange public token
      const exchangeResponse = await this.plaidClient.itemPublicTokenExchange({
        public_token: dto.publicToken,
      });

      const accessToken = exchangeResponse.data.access_token;
      const itemId = exchangeResponse.data.item_id;

      // Fetch Account details from Plaid to sync
      const accountsResponse = await this.plaidClient.accountsGet({
        access_token: accessToken,
      });

      // Create/Find Institution
      const instName = metadata.institution.name;
      let institution = await Institution.findOne({ where: { user: { id: user.id }, name: instName } });
      if (!institution) institution = await new Institution(this.config.url, instName, false, user).insert();

      // Store the Plaid credential linked to this institution
      let plaidAsset = await PlaidAsset.findOne({ where: { institution: { id: institution.id } } });
      if (!plaidAsset) {
        await new PlaidAsset(institution, accessToken, itemId).insert();
      } else {
        // Update token in case it changed during a re-auth flow
        plaidAsset.accessToken = accessToken;
        plaidAsset.itemId = itemId;
        await plaidAsset.update();
      }

      return await Promise.all(
        accountsResponse.data.accounts.map(async (acc) => {
          const newAccount = await new Account(
            acc.name,
            ProviderType.plaid,
            user,
            institution,
            acc.balances.current || 0,
            0,
            this.mapType(acc.type),
            acc.balances.iso_currency_code || "USD",
            this.mapSubType(acc.subtype),
          ).insert();
          await AccountHistory.insertForNewAccount(newAccount);
          return newAccount;
        }),
      );
    } catch (error) {
      throw new InternalServerErrorException("Failed to link Plaid accounts.");
    }
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
