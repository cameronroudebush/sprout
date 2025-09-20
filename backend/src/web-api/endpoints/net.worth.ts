import { Account } from "@backend/model/account";
import { AccountHistory } from "@backend/model/account.history";
import { RestEndpoints } from "@backend/model/api/endpoint";
import { EntityHistory } from "@backend/model/api/entity.history";
import { RestBody } from "@backend/model/api/rest.request";
import { User } from "@backend/model/user";
import { isSameDay, subDays, subYears } from "date-fns";
import { groupBy } from "lodash";
import { MoreThan } from "typeorm";
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

  /** Gets account history for the past year for the given user */
  private static async getHistory(user: User) {
    const oneYearAgo = subYears(new Date(), 1);
    const accountHistory = await AccountHistory.getDistinctHistoryByUser(user, {
      where: { time: MoreThan(oneYearAgo) },
      order: { time: "ASC" },
    });

    const accountsForUser = await Account.getForUser(user);
    // If we don't have anything from yesterday, add some fake data
    const yesterday = subDays(new Date(), 1);
    if (!accountHistory.find((x) => isSameDay(x.time, yesterday))) {
      accountHistory.push(
        ...accountsForUser.map((x) => {
          const history = x.toAccountHistory(yesterday);
          history.balance = 0;
          history.availableBalance = 0;
          return history;
        }),
      );
    }

    // Add today as account history, if we don't have any for today
    if (!accountHistory.find((x) => isSameDay(x.time, new Date()))) accountHistory.push(...(await Account.getForUser(user)).map((x) => x.toAccountHistory()));
    return accountHistory;
  }

  /** Returns various net-worth tracking over time */
  @RestMetadata.register(new RestMetadata(RestEndpoints.netWorth.getNetWorthOverTime, "GET"))
  async getNetWorthOT(_request: RestBody, user: User) {
    const accountHistory = await NetWorthAPI.getHistory(user);
    return EntityHistory.getForHistory(accountHistory);
  }

  /** Returns the net-worth of all accounts individually */
  @RestMetadata.register(new RestMetadata(RestEndpoints.netWorth.getNetWorthByAccount, "GET"))
  async getNetWorthByAccounts(_request: RestBody, user: User) {
    const accounts = await Account.getForUser(user);
    const completeAccountHistory = await NetWorthAPI.getHistory(user);
    const groupedAccounts = groupBy(completeAccountHistory, "account.id");
    // Loop over each account
    return Object.keys(groupedAccounts).map((accountId) => {
      const account = accounts.find((x) => x.id === accountId);
      const accountHistory = groupedAccounts[accountId]!;
      const ot = EntityHistory.getForHistory(accountHistory, account);
      ot.connectedId = accountId;
      return ot;
    });
  }
}
