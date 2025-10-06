import { Account } from "@backend/model/account";
import { AccountHistory } from "@backend/model/account.history";
import { RestEndpoints } from "@backend/model/api/endpoint";
import { EntityHistory } from "@backend/model/api/entity.history";
import { RestBody } from "@backend/model/api/rest.request";
import { User } from "@backend/model/user";
import { groupBy } from "lodash";
import { RestMetadata } from "../metadata";

/**
 * Class that provides net worth calculations for numerous locations
 */
export class NetWorthAPI {
  /** Returns the net-worth of all accounts  */
  @RestMetadata.register(new RestMetadata(RestEndpoints.netWorth.getNetWorth, "GET"))
  async getNetWorth(_request: RestBody, user: User) {
    // Calculate net worth from all accounts
    const accounts = await Account.find({ where: { user: { id: user.id } } });
    return accounts.reduce((acc, account) => acc + account.balance, 0);
  }

  /** Returns various net-worth tracking over time */
  @RestMetadata.register(new RestMetadata(RestEndpoints.netWorth.getNetWorthOverTime, "GET"))
  async getNetWorthOT(_request: RestBody, user: User) {
    const accountHistory = await AccountHistory.getHistoryForUser(user);
    return EntityHistory.getForHistory(AccountHistory, accountHistory);
  }

  /** Returns the net-worth of all accounts individually */
  @RestMetadata.register(new RestMetadata(RestEndpoints.netWorth.getNetWorthByAccount, "GET"))
  async getNetWorthByAccounts(_request: RestBody, user: User) {
    const accounts = await Account.getForUser(user);
    const accountHistory = await AccountHistory.getHistoryForUser(user);
    const groupedAccounts = groupBy(accountHistory, "account.id");
    // Loop over each account
    return Object.keys(groupedAccounts).map((accountId) => {
      const account = accounts.find((x) => x.id === accountId);
      const accountHistory = groupedAccounts[accountId]!;
      const ot = EntityHistory.getForHistory(AccountHistory, accountHistory, account);
      ot.connectedId = accountId;
      return ot;
    });
  }
}
