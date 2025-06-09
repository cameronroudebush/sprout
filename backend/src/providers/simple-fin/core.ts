import { Configuration } from "@backend/config/core";
import { Transaction } from "@backend/model/transaction";
import { SimpleFINReturn } from "@backend/providers/simple-fin/return.type";
import { Account, Holding, Institution } from "@common";
import { subDays } from "date-fns";
import { ProviderBase } from "../base/core";
import { ProviderRateLimit } from "../base/rate-limit";

import * as fakeData from "./fake-data.json";

/**
 * This provider adds automated account syncing using the SimpleFIN provider.
 */
export class SimpleFINProvider extends ProviderBase {
  override rateLimit: ProviderRateLimit = new ProviderRateLimit("simple-fin", Configuration.providers.simpleFIN.rateLimit);

  override async get() {
    // TODO: This needs to consider what accounts are linked, not just all accounts
    return this.convertData(await this.fetchData());
  }

  /** Converts the given SimpleFIN typed data to our own local models */
  private convertData(data: SimpleFINReturn.FinancialData) {
    return data.accounts.map((x) => {
      const hasInstitutionError = data.errors.some((z) => z.includes(x.org.name));
      const institution = Institution.fromPlain({ name: x.org.name, id: x.org.id, url: x.org.url, hasError: hasInstitutionError });
      const name = x.name;
      const balance = parseFloat(x.balance);
      const availableBalance = parseFloat(x["available-balance"]);
      // Try to determine our account type
      let type: Account["type"];
      if (availableBalance !== 0) type = "depository";
      else if (x.holdings.length !== 0) type = "investment";
      else if (balance <= 0 && (name.toLowerCase().includes("credit") || name.toLowerCase().includes("card"))) type = "credit";
      else type = "loan";
      const account = Account.fromPlain({ name, id: x.id, type, currency: x.currency, provider: "simple-fin", balance, availableBalance, institution });
      // Try to parse any holdings
      const holdings = x.holdings.map((hold) =>
        Holding.fromPlain({
          id: hold.id,
          currency: hold.currency,
          costBasis: parseFloat(hold.cost_basis),
          description: hold.description,
          marketValue: parseFloat(hold.market_value),
          purchasePrice: parseFloat(hold.purchase_price),
          shares: parseFloat(hold.shares),
          symbol: hold.symbol,
          account,
        }),
      );
      // Try to parse transactions
      const transactions = x.transactions.map((t) =>
        Transaction.fromPlain({
          id: t.id,
          posted: new Date(t.posted),
          amount: t.amount,
          description: t.description,
          pending: t.pending ?? false,
          category: t.extra?.category,
        }),
      );
      return {
        account,
        holdings,
        transactions,
      };
    });
  }

  /** Fetches data from SimpleFIN via rest requests */
  async fetchData(
    endpoint = "/accounts",
    params = {
      /** The start date to look for transactions of */
      transactionStartDate: new Date(),
      /** The end date to look for transactions of */
      transactionEndDate: subDays(new Date(), Configuration.providers.simpleFIN.lookBackDays),
      /** If we want pending transactions */
      pending: true,
    },
  ) {
    await this.rateLimit.incrementOrError();
    if (Configuration.providers.simpleFIN.accessToken == null) throw new Error("SimpleFIN access token is not properly configured within your configuration.");
    const url = `${Configuration.providers.simpleFIN.accessToken}${endpoint}?pending=${params.pending ? 1 : 0}&start-date=${params.transactionStartDate.getTime()}&end-date=${params.transactionEndDate.getTime()}`;
    // Pull out the authorization header
    const [user, pass] = url.replace("https://", "").split("@")[0]!.split(":");
    const cleanURL = url.replace(user!, "").replace(pass!, "").replace(":@", "");
    console.log(cleanURL);
    // TODO: Add back in actual query
    return fakeData as SimpleFINReturn.FinancialData;
    // const result = await fetch(cleanURL, { method: "GET", headers: { Authorization: "Basic " + btoa(`${user}:${pass}`) } });
    // return await result.json() as SimpleFINReturn.FinancialData
  }
}
