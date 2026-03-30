import { Configuration } from "@backend/config/core";
import { User } from "@backend/user/model/user.model";
import { firstValueFrom } from "rxjs";
import { ProviderBase } from "../base/core";
import { ProviderRateLimit } from "../base/rate-limit";

// interface ZillowSearchResult {
//   zpid: string;
//   address: {
//     street: string;
//     zipcode: string;
//     city: string;
//     state: string;
//   };
//   links: {
//     homedetails: string;
//     graphsanddata: string;
//     mapthishome: string;
//   };
// }

/**
 * This provider adds automated property lookup via the Zillow API
 */
export class ZillowProvider extends ProviderBase {
  private readonly zwsid = "YOUR_ZILLOW_ZWSID";
  private readonly baseUrl = "http://www.zillow.com/webservice";

  override rateLimit = (user?: User) => new ProviderRateLimit("zillow", Configuration.providers.zillow.rateLimit, user);

  override async get(_user: User, _accountsOnly: boolean) {
    return [];
  }

  //   /**
  //    * Orchestrator: Find ZPID then get the value
  //    */
  //   async getHouseValueByAddress(address: string, cityStateZip: string) {
  //     const zpid = await this.getZpidByAddress(address, cityStateZip);
  //     return this.getZestimate(zpid);
  //   }

  /**
   * Get ZPID from address strings
   */
  async getZpidByAddress(address: string, citystatezip: string) {
    const url = `${this.baseUrl}/GetDeepSearchResults.htm`;

    const response = await firstValueFrom(
      this.httpService.get(url, {
        params: { "zws-id": this.zwsid, address, citystatezip },
      }),
    );

    console.log(response);
  }

  //   /**
  //    * Get Valuation (Zestimate) from ZPID
  //    */
  //   private async getZestimate(zpid: string) {
  //     const url = `${this.baseUrl}/GetZestimate.htm`;

  //     const response = await firstValueFrom(
  //       this.httpService.get(url, {
  //         params: { 'zws-id': this.zwsid, zpid }
  //       })
  //     );

  //     const result = await parseStringPromise(response.data);
  //     const root = result['Zestimate:zestimate'];

  //     if (root['message'][0]['code'][0] !== '0') {
  //       throw new InternalServerErrorException(`Zestimate Error: ${root['message'][0]['text'][0]}`);
  //     }

  //     const data = root['response'][0]['zestimate'][0];
  //     const range = data['valuationRange'][0];

  //     return {
  //       zpid,
  //       price: parseFloat(data['amount'][0]['_']),
  //       high: parseFloat(range['high'][0]['_']),
  //       low: parseFloat(range['low'][0]['_']),
  //       lastUpdated: data['last-updated'][0],
  //       currency: data['amount'][0]['$']['currency']
  //     };
  //   }
}

// await fetch("https://www.zillow.com/graphql/?extensions=%7B%22persistedQuery%22%3A%7B%22version%22%3A1%2C%22sha256Hash%22%3A%2238ad82b1a26d69e6da3132e7a49df10eeaea116815ddf10d971a47aa8df41da1%22%7D%7D&variables=%7B%22zpid%22%3A337649711%2C%22altId%22%3Anull%2C%22deviceTypeV2%22%3A%22WEB_DESKTOP%22%2C%22includeLastSoldListing%22%3Afalse%7D", {
//     "credentials": "include",
//     "headers": {
//         "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:148.0) Gecko/20100101 Firefox/148.0",
//         "Accept": "*/*",
//         "Accept-Language": "en-US,en;q=0.9",
//         "content-type": "application/json",
//         "client-id": "not-for-sale-sub-app-browser-client",
//         "x-z-enable-oauth-conversion": "true",
//         "Sec-Fetch-Dest": "empty",
//         "Sec-Fetch-Mode": "cors",
//         "Sec-Fetch-Site": "same-origin",
//         "Priority": "u=4",
//         "Pragma": "no-cache",
//         "Cache-Control": "no-cache"
//     },
//     "referrer": "https://www.zillow.com/homedetails/4037-Lupine-Way-Tipp-City-OH-45371/337649711_zpid/",
//     "method": "GET",
//     "mode": "cors"
// });
