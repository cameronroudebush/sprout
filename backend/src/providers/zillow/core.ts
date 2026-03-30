import { Configuration } from "@backend/config/core";
import { User } from "@backend/user/model/user.model";
import puppeteer from "puppeteer-extra";
import StealthPlugin from "puppeteer-extra-plugin-stealth";
import { ProviderBase } from "../base/core";
import { ProviderRateLimit } from "../base/rate-limit";

/**
 * This provider adds automated property lookup via the Zillow API
 */
export class ZillowProvider extends ProviderBase {
  // private logger = new Logger("provider:zillow");

  override rateLimit = (user?: User) => new ProviderRateLimit("zillow", Configuration.providers.zillow.rateLimit, user);

  override async get(_user: User, _accountsOnly: boolean) {
    return [];
  }

  /** Given a number as as tring, cleans it up and returns it as an actual number */
  private cleanNumber(value?: string) {
    if (value == null) return undefined;
    return parseInt(value.replace(/,/g, ""), 10);
  }

  /**
   * Gets property info for the given address information. This includes the zestimates and the zid
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
      const rentMatch = content.match(/Rent Zestimate.*?\$([\d,]+)/);
      return {
        zpid,
        zestimate: zestMatch ? this.cleanNumber(zestMatch[1]) : null,
        rentZestimate: rentMatch ? this.cleanNumber(rentMatch[1]) : null,
      };
    } finally {
      await browser.close();
    }
  }
}

// TODO: Reduce how often we sync, make it configurable per provider
