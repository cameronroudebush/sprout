import { PlaidInstitutionHandler } from "@backend/financeAPI/plaid/institution";
import { PlaidTokenHandler } from "@backend/financeAPI/plaid/token";
import { User } from "@common";
import { PlaidApi } from "plaid";
import { Configuration } from "../../config/core";
import { FinanceAPIBase } from "../base/core";

/** Core API handling for talking to plaid services */
export class PlaidCore extends FinanceAPIBase {
  constructor(
    configuration = Configuration.plaid,
    /** The plaid configuration that should already be loaded. */
    plaidClientConfig = configuration.config,
    /** The client for talking with plaid. */
    private client = new PlaidApi(plaidClientConfig),
    /** Handler for looking up institution information */
    institutionHandler = new PlaidInstitutionHandler(client, configuration),
    /** Handler for getting the keys necessary for Plaid API lookups */
    private keyHandler = new PlaidTokenHandler(client, institutionHandler)
  ) {
    super();
  }

  async getTransactions(_user: User) {
    const accessToken = await this.keyHandler.getAccessToken(await this.keyHandler.getPublicToken());
    return (await this.client.transactionsGet({ access_token: accessToken, start_date: "2024-01-01", end_date: "2024-03-06" })).data.transactions;
    // return (await this.client.transactionsSync({ access_token: accessToken }));
  }

  async getAccounts(_user: User): Promise<any> {
    const accessToken = await this.keyHandler.getAccessToken(await this.keyHandler.getPublicToken());
    return (await this.client.accountsGet({ access_token: accessToken })).data.accounts;
  }

  // // TODO Break apart
  // async test() {
  //   try {
  //     console.log(this.configuration);

  //     // Account filtering isn't required here, but sometimes
  //     // it's helpful to see an example.

  //     //   const request: LinkTokenCreateRequest = {
  //     //     user: {
  //     //       client_user_id: "user-id",
  //     //       phone_number: "+1 415 5550123",
  //     //     },
  //     //     client_name: "Personal Finance App",
  //     //     products: [Products.Transactions],
  //     //     transactions: {
  //     //       days_requested: 10,
  //     //     },
  //     //     country_codes: [CountryCode.Us],
  //     //     language: "en",
  //     //     webhook: "https://sample-web-hook.com",
  //     //     account_filters: {
  //     //       depository: {
  //     //         account_subtypes: [DepositoryAccountSubtype.Checking, DepositoryAccountSubtype.Savings],
  //     //       },
  //     //       credit: {
  //     //         account_subtypes: [CreditAccountSubtype.CreditCard],
  //     //       },
  //     //     },
  //     //   };
  //     //   const response = await plaidClient.linkTokenCreate(request);
  //     //   const linkToken = response.data.link_token;
  //     const institutions = (await plaidClient.institutionsGet({ count: 10, offset: 0, country_codes: [CountryCode.Us] })).data.institutions;
  //     const public_token = (
  //       await plaidClient.sandboxPublicTokenCreate({ institution_id: institutions[1]!.institution_id, initial_products: [Products.Transactions] })
  //     ).data.public_token;
  //     //   const public_token = (
  //     //     await plaidClient.linkTokenCreate({
  //     //       client_name: Configuration.appName,
  //     //       language: "en",
  //     //       country_codes: [CountryCode.Us],
  //     //       user: { client_user_id: "foobar" },
  //     //     })
  //     //   ).data.link_token;

  //     const access_token = (await plaidClient.itemPublicTokenExchange({ public_token })).data.access_token;
  //     //   const access_token = response.data.access_token;
  //     const accounts = await plaidClient.accountsGet({ access_token: access_token });
  //     console.log(accounts.data.accounts);
  //     //   const accounts = accounts_response.data.accounts;
  //     // const result = await plaidClient.transactionsSync();
  //     //   console.log(accounts);
  //   } catch (e) {
  //     console.log(e);
  //   }
  // }
}
