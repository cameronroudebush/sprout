import { Configuration } from "@backend/config/core";
import { Logger } from "@backend/logger";
import { Account } from "@backend/model/account";
import { Category } from "@backend/model/category";
import { Holding } from "@backend/model/holding";
import { Institution } from "@backend/model/institution";
import { Transaction } from "@backend/model/transaction";
import { User } from "@backend/model/user";
import { DevFinancialDataGenerator } from "@backend/providers/base/random-data";
import { SimpleFINReturn } from "@backend/providers/simple-fin/return.type";
import { subDays } from "date-fns";
import { ProviderBase } from "../base/core";
import { ProviderRateLimit } from "../base/rate-limit";

/**
 * This provider adds automated account syncing using the SimpleFIN provider.
 */
export class SimpleFINProvider extends ProviderBase {
  override rateLimit: ProviderRateLimit = new ProviderRateLimit("simple-fin", Configuration.providers.simpleFIN.rateLimit);

  override async get(user: User, accountsOnly: boolean) {
    return this.convertData(await this.fetchData(undefined, undefined, accountsOnly), user);
  }

  /** Converts the given SimpleFIN typed data to our own local models */
  private async convertData(data: SimpleFINReturn.FinancialData, user: User) {
    return await Promise.all(
      data.accounts.map(async (x) => {
        const hasInstitutionError = data.errors.some((z) => z.includes(x.org.name));
        const institution = Institution.fromPlain({ name: x.org.name, id: x.org.id, url: x.org.url, hasError: hasInstitutionError });
        const name = x.name;
        const balance = parseFloat(x.balance);
        const availableBalance = parseFloat(x["available-balance"]);
        // Try to determine our account type
        let type: Account["type"];
        if (balance <= 0 && (name.toLowerCase().includes("credit") || name.toLowerCase().includes("card"))) type = "credit";
        else if (x.holdings.length !== 0) type = "investment";
        else if (availableBalance !== 0) type = "depository";
        else type = "loan";
        const account = Account.fromPlain({
          name,
          id: x.id,
          type,
          currency: x.currency,
          provider: "simple-fin",
          balance,
          availableBalance,
          institution,
          extra: x.extra,
        });
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
        const transactions = await Promise.all(
          x.transactions.map(async (t) => {
            const category = await Category.getOrCreate(t.extra?.category, user);
            return Transaction.fromPlain({
              id: t.id,
              posted: new Date(t.posted * 1000),
              amount: t.amount,
              description: t.description,
              pending: t.pending ?? false,
              category,
              extra: t.extra,
            });
          }),
        );
        return {
          account,
          holdings,
          transactions,
        };
      }),
    );
  }

  /**
   * Fetches data from SimpleFIN via rest requests
   *
   * @param balancesOnly If we don't want transactional data. Default is false so we do want transactional data.
   */
  async fetchData(
    endpoint = "/accounts",
    params = {
      /** The start date to look for transactions of */
      transactionStartDate: subDays(new Date(), Configuration.providers.simpleFIN.lookBackDays),
      /** If we want pending transactions */
      pending: true,
    },
    balancesOnly: boolean,
  ) {
    if (Configuration.providers.simpleFIN.accessToken == null) throw new Error("SimpleFIN access token is not properly configured within your configuration.");
    const startDateEpoch = Math.round(params.transactionStartDate.getTime() / 1000);
    const url = `${Configuration.providers.simpleFIN.accessToken}${endpoint}?pending=${params.pending ? 1 : 0}&start-date=${startDateEpoch}&balances-only=${balancesOnly ? 1 : 0}`;
    // Pull out the authorization header
    const [user, pass] = url.replace("https://", "").split("@")[0]!.split(":");
    const cleanURL = url.replace(user!, "").replace(pass!, "").replace(":@", "");
    if (Configuration.isDevBuild) {
      Logger.warn(`Dev build detected. SimpleFIN will return fake data.`);
      return new DevFinancialDataGenerator().generateFinancialData(true) as any as SimpleFINReturn.FinancialData;
    } else {
      await this.rateLimit.incrementOrError();
      const result = await fetch(cleanURL, { method: "GET", headers: { Authorization: "Basic " + btoa(`${user}:${pass}`) } });
      return (await result.json()) as SimpleFINReturn.FinancialData;
    }
  }
}
