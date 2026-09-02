import { Account } from "@backend/account/model/account.model";
import { AccountSubType } from "@backend/account/model/account.sub.type";
import { AccountType } from "@backend/account/model/account.type";
import { Configuration } from "@backend/config/core";
import { Institution } from "@backend/institution/model/institution.model";
import { ExchangeInstitution, ProviderBase, ProviderSyncResult } from "@backend/providers/base/core";
import { ProviderConfig } from "@backend/providers/base/model/provider.config.model";
import { ProviderSubType, ProviderType } from "@backend/providers/base/provider.type";
import { ProviderRateLimit } from "@backend/providers/base/rate-limit";
import { ZillowPropertyDTO } from "@backend/providers/zillow/model/api/zillow.lookup.dto";
import { ZillowPropertyResultDto } from "@backend/providers/zillow/model/api/zillow.result.dto";
import { User } from "@backend/user/model/user.model";
import { BadRequestException, Injectable, Logger, NotImplementedException } from "@nestjs/common";
import { Impit } from "impit";

/** Extended type carrying address string down to mapToSproutAccount */
export interface ZillowRawPropertyPayload {
  result: ZillowPropertyResultDto;
  address: string;
}

/**
 * This provider adds automated property lookup via Zillow.
 *
 * Note: Because real estate properties do not have "Institutions" or "OAuth Tokens",
 * this service directly overrides the get() sync loop and explicitly stubs out
 * the exchange/linking hooks.
 */
@Injectable()
export class ZillowProviderService extends ProviderBase<void, void, ZillowPropertyDTO, void, ZillowRawPropertyPayload, undefined> {
  protected readonly logger = new Logger("provider:service:zillow");
  override getAppConfiguration = () => Configuration.providers.zillow;
  config = new ProviderConfig("Zillow", ProviderType.zillow, ProviderSubType.realEstate, "https://www.zillow.com");
  override rateLimit = (user?: User) => new ProviderRateLimit(ProviderType.zillow, Configuration.providers.zillow.rateLimit, user);
  override isAvailable = async (_user: User) => true;

  /** Impit instance used for scraping */
  private readonly impit = new Impit({ browser: "chrome" });

  /**
   * Overrides the template method get() because Zillow properties are tracked
   * individually via providerAccountId (ZPID), not grouped under an Institution connection.
   */
  override async get(user: User, _accountsOnly: boolean, _institutionId?: string): Promise<ProviderSyncResult[]> {
    const accounts = await Account.find({ where: { user: { id: user.id }, provider: ProviderType.zillow } });
    const results: ProviderSyncResult[] = [];

    for (const account of accounts) {
      const zpid = account.providerAccountId;
      if (!zpid) {
        this.logger.warn(`No zpid found for account ${account.id}`);
        continue;
      }

      try {
        const data = await this.getInfoByZpid(user, zpid);
        account.balance = data.zestimate;
        account.availableBalance = data.zestimate;
        results.push({ account, providerAccountId: zpid });
      } catch (e) {
        this.logger.error(`Failed to update Zillow account ${account.id}`, e);
      }
    }

    return results;
  }

  override async generateLinkToken(): Promise<void> {
    throw new NotImplementedException("Zillow properties are linked manually via address search, not OAuth tokens.");
  }

  /** Given a number as a string, cleans it up and returns it as an actual number */
  private cleanNumber(value?: string): number | undefined {
    if (value == null) return undefined;
    return parseInt(value.replace(/,/g, ""), 10);
  }

  /** Given the page content, returns the parsed Zillow data if it can be found */
  private resultFromContent(content: string): ZillowPropertyResultDto {
    const match = content.match(/"zpid":\d*/gm);
    const zpid = match?.[1]?.replace('"zpid":', "");

    const zestMatch = content.match(/Zestimate.*?\$([\d,]+)/);
    const zestimate = this.cleanNumber(zestMatch?.[1]) ?? 0;

    const rentMatch = content.match(/Rent Zestimate.*?\$([\d,]+)/);
    const rentZestimate = this.cleanNumber(rentMatch?.[1]) ?? 0;

    const currencyMatch = content.match(/"priceCurrency":"\w*"/gm);
    const currency = currencyMatch?.[0].replaceAll('"priceCurrency":"', "").replaceAll('"', "");

    if (zpid == null || zpid === "35072756" || zestimate === 50000 || !currency) {
      throw new BadRequestException("Failed to locate the property on Zillow.");
    }

    return new ZillowPropertyResultDto(zpid, zestimate, rentZestimate, currency);
  }

  /** Given a search URL, returns the content from the page */
  private async getByUrl(searchUrl: string): Promise<string> {
    const response = await this.impit.fetch(searchUrl);
    const content = await response.text();

    if (content.includes("px-captcha") || content.includes("Access to this page has been denied")) {
      throw new Error("Provider temporarily unavailable due to rate limits.");
    }

    return content;
  }

  /** Gets property info for the given address information. */
  async getInfoByAddress(user: User, address: string, city: string, state: string, zip: number): Promise<ZillowPropertyResultDto> {
    await this.rateLimit(user).incrementOrError();
    const completeAddress = `${address} ${city}, ${state} ${zip}`.replace(/\s+/g, "-");
    const searchUrl = `https://www.zillow.com/homes/${completeAddress}_rb/`;
    const content = await this.getByUrl(searchUrl);
    return this.resultFromContent(content);
  }

  /** Gets property info for the given zpid. */
  async getInfoByZpid(user: User, zpid: string): Promise<ZillowPropertyResultDto> {
    await this.rateLimit(user).incrementOrError();
    const searchUrl = `https://www.zillow.com/homes/${zpid}_zpid/`;
    const content = await this.getByUrl(searchUrl);
    return this.resultFromContent(content);
  }

  public override async performExchange(user: User, payload: ZillowPropertyDTO): Promise<ExchangeInstitution<void, ZillowRawPropertyPayload>[]> {
    const { address, city, state, zip } = payload;
    const propertyInfo = await this.getInfoByAddress(user, address, city, state, zip);

    if (!propertyInfo.zpid || propertyInfo.zestimate === null) {
      throw new BadRequestException("Could not verify property information with Zillow.");
    }

    return [
      {
        institutionName: "Zillow",
        institutionUrl: this.config.url,
        authContext: undefined,
        rawAccounts: [{ result: propertyInfo, address }],
      },
    ];
  }

  protected override extractProviderAccountId(rawAccount: ZillowRawPropertyPayload): string {
    return rawAccount.result.zpid;
  }

  protected override extractAccountName(rawAccount: ZillowRawPropertyPayload): string {
    return rawAccount.address;
  }

  protected override async mapToSproutAccount(
    rawAccount: ZillowRawPropertyPayload,
    _authContext: void,
    user: User,
    institution: Institution,
  ): Promise<Account> {
    return new Account(
      rawAccount.address,
      ProviderType.zillow,
      rawAccount.result.zpid,
      user,
      institution,
      rawAccount.result.zestimate,
      0,
      AccountType.asset,
      rawAccount.result.currency || "USD",
      AccountSubType.house,
    );
  }

  protected async performSync(): Promise<ProviderSyncResult[]> {
    throw new NotImplementedException();
  }

  protected async getInstitutionAssetsForUser(): Promise<undefined[]> {
    return [];
  }
}
