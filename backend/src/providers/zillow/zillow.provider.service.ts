import { Account } from "@backend/account/model/account.model";
import { Configuration } from "@backend/config/core";
import { ProviderConfig } from "@backend/providers/base/model/provider.config.model";
import { ProviderType } from "@backend/providers/base/provider.type";
import { ZillowPropertyResultDto } from "@backend/providers/zillow/model/api/zillow.result.dto";
import { ZillowAsset } from "@backend/providers/zillow/model/zillow.asset";
import { User } from "@backend/user/model/user.model";
import { Injectable, Logger } from "@nestjs/common";
import { Impit } from "impit";
import { cloneDeep } from "lodash";
import { ProviderBase } from "../base/core";
import { ProviderRateLimit } from "../base/rate-limit";

/**
 * This provider adds automated property lookup via Zillow.
 */
@Injectable()
export class ZillowProviderService extends ProviderBase {
  override getAppConfiguration = () => Configuration.providers.zillow;
  private readonly logger = new Logger("provider:service:zillow");
  config = new ProviderConfig("Zillow", ProviderType.zillow, "https://www.zillow.com", "https://www.zillow.com/apple-touch-icon.png");
  override rateLimit = (user?: User) => new ProviderRateLimit(ProviderType.zillow, Configuration.providers.zillow.rateLimit, user);
  /** Impit instance used for scraping */
  private readonly impit = new Impit({ browser: "chrome" });

  override async get(user: User, _accountsOnly: boolean) {
    const accounts = await Account.find({ where: { user: { id: user.id }, provider: ProviderType.zillow } });
    return await Promise.all(
      accounts.map(async (x) => {
        const info = await ZillowAsset.findOne({ where: { account: { id: x.id } } });
        if (!info || !info.zpid) this.logger.warn(`No zpid info found for account ${x.id}`);
        const data = await this.getInfoByZpid(user, info!.zpid);
        const account = cloneDeep(x);
        account.balance = data.zestimate;
        account.availableBalance = data.zestimate;
        return {
          account,
          holdings: undefined,
          transactions: undefined,
        };
      }),
    );
  }

  /** Given a number as as tring, cleans it up and returns it as an actual number */
  private cleanNumber(value?: string) {
    if (value == null) return undefined;
    return parseInt(value.replace(/,/g, ""), 10);
  }

  /** Given the page content, returns the parsed zillow data if it can be found */
  private resultFromContent(content: string) {
    // Find the zpid
    const match = content.match(/"zpid":\d*/gm);
    const zpid = match?.[1]?.replace('"zpid":', "");
    // Find the zestimate data
    const zestMatch = content.match(/Zestimate.*?\$([\d,]+)/);
    const zestimate = this.cleanNumber(zestMatch?.[1]) ?? 0;
    const rentMatch = content.match(/Rent Zestimate.*?\$([\d,]+)/);
    const rentZestimate = this.cleanNumber(rentMatch?.[1]) ?? 0;
    return new ZillowPropertyResultDto(zpid!, zestimate, rentZestimate);
  }

  /**
   * Gets property info for the given address information. This includes the zestimates and the zid. This is accomplished using
   *  web scraping.
   * @param address The street address
   * @param city The city of the property
   * @param state The state in a two digit state code
   * @param zip The zip code
   * @returns
   */
  async getInfoByAddress(user: User, address: string, city: string, state: string, zip: number) {
    await this.rateLimit(user).incrementOrError();
    const completeAddress = `${address} ${city}, ${state} ${zip}`.replace(/\s+/g, "-");
    const searchUrl = `https://www.zillow.com/homes/${completeAddress}_rb/`;
    const response = await this.impit.fetch(searchUrl);
    const content = await response.text();
    return this.resultFromContent(content);
  }

  /**
   * Gets property info for the given zpid. Accomplishes this by using puppeteer to scrape the webpage
   * @param zpid The Zillow Property ID
   */
  async getInfoByZpid(user: User, zpid: string) {
    await this.rateLimit(user).incrementOrError();
    const searchUrl = `https://www.zillow.com/homes/${zpid}_zpid/`;
    const response = await this.impit.fetch(searchUrl);
    const content = await response.text();
    return this.resultFromContent(content);
  }
}
