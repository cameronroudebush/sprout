import { Account } from "@backend/account/model/account.model";
import { AccountType } from "@backend/account/model/account.type";
import { Category } from "@backend/category/model/category.model";
import { Configuration } from "@backend/config/core";
import { Holding } from "@backend/holding/model/holding.model";
import { Institution } from "@backend/institution/model/institution.model";
import { SimpleFINReturn } from "@backend/providers/simple-fin/return.type";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { BadRequestException } from "@nestjs/common";
import { subDays } from "date-fns";
import { ProviderBase } from "../base/core";
import { ProviderRateLimit } from "../base/rate-limit";

/**
 * This provider adds automated account syncing using the SimpleFIN provider.
 */
export class SimpleFINProvider extends ProviderBase {
  override rateLimit = (user?: User) => new ProviderRateLimit("simple-fin", Configuration.providers.simpleFIN.rateLimit, user);

  override async get(user: User, accountsOnly: boolean) {
    return this.convertData(await this.fetchData(undefined, undefined, accountsOnly, user), user);
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
        if (balance <= 0 && (name.toLowerCase().includes("credit") || name.toLowerCase().includes("card"))) type = AccountType.credit;
        else if (name.toLowerCase().includes("wallet") || name.toLowerCase().includes("staked"))
          type = AccountType.crypto; // Crypto is considered if it contains "wallet" or "staked"
        else if (x.holdings.length !== 0) type = AccountType.investment;
        else if (availableBalance !== 0) type = AccountType.depository;
        else type = AccountType.loan;
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
    user: User,
  ) {
    const accessToken = user.config.simpleFinToken;

    if (accessToken == null) throw new Error("SimpleFIN access token is not properly configured. Make sure one is set within the user settings.");
    const startDateEpoch = Math.round(params.transactionStartDate.getTime() / 1000);
    const url = `${accessToken}${endpoint}?pending=${params.pending ? 1 : 0}&start-date=${startDateEpoch}&balances-only=${balancesOnly ? 1 : 0}`;
    // Pull out the authorization header
    const [username, pass] = url.replace("https://", "").split("@")[0]!.split(":");
    const cleanURL = url.replace(username!, "").replace(pass!, "").replace(":@", "");
    await this.rateLimit(user).incrementOrError();
    const result = await fetch(cleanURL, { method: "GET", headers: { Authorization: "Basic " + btoa(`${username}:${pass}`) } });
    return (await result.json()) as SimpleFINReturn.FinancialData;
  }

  /**
   * Given the setup token from SimpleFIN, converts it into an API token that will be used for accessing the
   *  API for the user.
   *
   * This can only ever be done once per setupToken.
   */
  async convertSetupToken(setupToken: string) {
    // Base64 decode the setup token to get the Claim URL
    const claimUrl = Buffer.from(setupToken, "base64").toString("utf-8");
    try {
      new URL(claimUrl); // Validate URL
    } catch (e) {
      throw new BadRequestException("Failed to parse claimUrl. Are you sure you only included the 'setup token'?");
    }
    // Issue a POST request to the Claim URLs
    const claimResponse = await fetch(claimUrl, {
      method: "POST",
      headers: {
        "Content-Length": "0",
      },
    });
    if (!claimResponse.ok) throw new Error(`Failed to exchange token. Status: ${claimResponse.status}. Remember: Setup tokens are one-time use.`);
    // The response body is the access token
    return await claimResponse.text();
  }
}
