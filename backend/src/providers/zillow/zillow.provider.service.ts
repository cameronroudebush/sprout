import { Configuration } from "@backend/config/core";
import { ProviderConfig } from "@backend/providers/base/model/provider.config.model";
import { ProviderType } from "@backend/providers/base/provider.type";
import { ZillowPropertyResultDto } from "@backend/providers/zillow/model/api/zillow.result.dto";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";
import puppeteer from "puppeteer-extra";
import StealthPlugin from "puppeteer-extra-plugin-stealth";
import { ProviderBase } from "../base/core";
import { ProviderRateLimit } from "../base/rate-limit";

/**
 * This provider adds automated property lookup via Zillow.
 */
@Injectable()
export class ZillowProviderService extends ProviderBase {
  config = new ProviderConfig("Zillow", ProviderType.zillow, "https://www.zillow.com", "https://www.zillow.com/apple-touch-icon.png");

  override rateLimit = (user?: User) => new ProviderRateLimit(ProviderType.zillow, Configuration.providers.zillow.rateLimit, user);

  override async get(_user: User, _accountsOnly: boolean) {
    return [];
  }

  /** Given a number as as tring, cleans it up and returns it as an actual number */
  private cleanNumber(value?: string) {
    if (value == null) return undefined;
    return parseInt(value.replace(/,/g, ""), 10);
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
  async getPropertyInfo(address: string, city: string, state: string, zip: number) {
    const completeAddress = `${address} ${city}, ${state} ${zip}`.replace(/\s+/g, "-");
    puppeteer.use(StealthPlugin());
    const browser = await puppeteer.launch({ headless: true });
    const page = await browser.newPage();

    try {
      const searchUrl = `https://www.zillow.com/homes/${completeAddress}_rb/`;
      await page.goto(searchUrl, { waitUntil: "domcontentloaded" });
      const content = await page.content();
      // Find the zpid
      const match = content.match(/"zpid":\d*/gm);
      const zpid = match?.[1]?.replace('"zpid":', "");
      // Find the zestimate data
      const zestMatch = content.match(/Zestimate.*?\$([\d,]+)/);
      const zestimate = this.cleanNumber(zestMatch?.[1]) ?? 0;
      const rentMatch = content.match(/Rent Zestimate.*?\$([\d,]+)/);
      const rentZestimate = this.cleanNumber(rentMatch?.[1]) ?? 0;
      return new ZillowPropertyResultDto(zpid!, zestimate, rentZestimate);
    } finally {
      await browser.close();
    }
  }
}
