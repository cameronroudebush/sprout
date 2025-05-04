import { PlaidConfiguration } from "@backend/config/plaid.config";
import { PlaidInstitutionHandler } from "@backend/financeAPI/plaid/institution";
import { PlaidTokenHandler } from "@backend/financeAPI/plaid/token";
import { Transaction } from "@backend/model/transaction";
import { Account, User, Utility } from "@common";
import { PlaidApi, TransactionsUpdateStatus } from "plaid";
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
    private keyHandler = new PlaidTokenHandler(client, institutionHandler),
    private token?: string, // TODO: Probably need to change how this works
  ) {
    super();
    if (configuration.secret === new PlaidConfiguration().secret) throw new Error("You must update the Plaid credentials for this to work.");
  }

  async getAccessToken() {
    if (this.token == null) this.token = await this.keyHandler.getAccessToken(await this.keyHandler.getPublicToken());
    return this.token;
  }

  async getTransactions(user: User) {
    const token = await this.getAccessToken();
    const accounts = await this.getAccounts(user);
    let transactions: Transaction[] = [];
    let hasMoreTransactions = true;
    let cursor: string | undefined = undefined;

    // Keep fetching transactions until we get them all
    while (hasMoreTransactions) {
      const response = await this.client.transactionsSync({
        access_token: token,
        cursor,
        count: 500,
        options: {
          include_original_description: true,
        },
      });
      // Wait incase it's still updating
      if (response.data.transactions_update_status === TransactionsUpdateStatus.NotReady) {
        await Utility.delay(5000);
        continue;
      }
      // Filter transactions for this account
      const addedTransactions = response.data.added.map((x) =>
        Transaction.fromPlain({ amount: x.amount, date: x.date, id: x.transaction_id, user, account: accounts.find((z) => z.apiId === x.account_id) }),
      );
      transactions = [...transactions, ...addedTransactions];
      hasMoreTransactions = response.data.has_more;
    }
    return transactions;
  }

  async getAccounts(_user: User) {
    const token = await this.getAccessToken();
    const accounts = (await this.client.accountsGet({ access_token: token })).data.accounts;
    return accounts.map((x) => Account.fromPlain({ name: x.name, source: "plaid", apiId: x.account_id }));
  }
}
