import { Account } from "@backend/model/account";
import { AccountHistory } from "@backend/model/account.history";
import { RestEndpoints } from "@backend/model/api/endpoint";
import { NetWorthFrameData, NetWorthOverTime } from "@backend/model/api/net.worth";
import { RestBody } from "@backend/model/api/rest.request";
import { User } from "@backend/model/user";
import { eachDayOfInterval, isSameDay, subDays, subYears } from "date-fns";
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

  /** Converts the given snapshot to historical data in a dictionary format. */
  private static snapshotToHistoricalDict(snapshot: Array<{ date: Date; netWorth: number }>) {
    return snapshot.reduce((acc, curr) => ({ ...acc, [curr.date.toISOString().split("T")[0]!]: curr.netWorth }), {});
  }

  /** Gets account history for the past year for the given user */
  private static async getHistory(user: User) {
    const oneYearAgo = subYears(new Date(), 1);
    const accountHistory = await AccountHistory.getDistinctHistoryByUser(user, {
      where: { time: MoreThan(oneYearAgo) },
      order: { time: "ASC" },
    });
    // Add today as account history, if we don't have any for today
    if (!accountHistory.find((x) => isSameDay(x.time, new Date()))) accountHistory.push(...(await Account.getForUser(user)).map((x) => x.toAccountHistory()));
    return accountHistory;
  }

  /**
   * Generates net worth over time for the given days. Returns the history snapshot for
   *  those days and the percent change averaged over that time period.
   */
  private static generateNetWorthOverTime(history: AccountHistory[], days: number) {
    if (history.length === 0) return { snapshot: [], percentageChange: 0 };
    const today = new Date();

    const netWorthSnapshots: Array<{ date: Date; netWorth: number }> = [];

    // Populate snapshot for every of the last N days
    const daysInArray = eachDayOfInterval({ start: subDays(today, days), end: today });
    for (const day of daysInArray) {
      const historyForDay = history.filter((x) => isSameDay(x.time, day));
      const netWorth = historyForDay.reduce((prev, curr) => (prev += curr.balance), 0);
      netWorthSnapshots.push({ date: day, netWorth });
    }

    // Calculate the percentage change
    const firstNetWorth = netWorthSnapshots.find((x) => x.netWorth !== 0)?.netWorth; // Find first net worth that is non-zero
    const lastNetWorth = netWorthSnapshots[netWorthSnapshots.length - 1]?.netWorth;
    let percentChange: number | null = null;
    let valueChange = 0;
    if (firstNetWorth && lastNetWorth) {
      percentChange = ((lastNetWorth - firstNetWorth) / firstNetWorth) * 100;
      valueChange = lastNetWorth - firstNetWorth;
    }
    const account = history.at(0)?.account;
    // Check if this is a drain on finances because a decrease is actually an increase
    if (account?.isNegativeNetWorth) {
      if (percentChange) percentChange = percentChange * -1;
      valueChange = valueChange * -1;
    }
    return { snapshot: netWorthSnapshots, frame: NetWorthFrameData.fromPlain({ percentChange, valueChange }) };
  }

  /** Returns various net-worth tracking over time */
  @RestMetadata.register(new RestMetadata(RestEndpoints.netWorth.getNetWorthOverTime, "GET"))
  async getNetWorthOT(_request: RestBody, user: User) {
    const accountHistory = await NetWorthAPI.getHistory(user);

    const last1Day = NetWorthAPI.generateNetWorthOverTime(accountHistory, 1);
    const last7Days = NetWorthAPI.generateNetWorthOverTime(accountHistory, 7);
    const last30Days = NetWorthAPI.generateNetWorthOverTime(accountHistory, 30);
    const lastYear = NetWorthAPI.generateNetWorthOverTime(accountHistory, 365);

    return NetWorthOverTime.fromPlain({
      last1Day: last1Day.frame,
      last7Days: last7Days.frame,
      last30Days: last30Days.frame,
      lastYear: lastYear.frame,
      historicalData: NetWorthAPI.snapshotToHistoricalDict(lastYear.snapshot),
    });
  }

  /** Returns the net-worth of all accounts individually */
  @RestMetadata.register(new RestMetadata(RestEndpoints.netWorth.getNetWorthByAccount, "GET"))
  async getNetWorthByAccounts(_request: RestBody, user: User) {
    const completeAccountHistory = await NetWorthAPI.getHistory(user);
    const groupedAccounts = groupBy(completeAccountHistory, "account.id");
    // Loop over each account
    return Object.keys(groupedAccounts).map((accountId) => {
      const accountHistory = groupedAccounts[accountId]!;

      const last1Day = NetWorthAPI.generateNetWorthOverTime(accountHistory, 1);
      const last7Days = NetWorthAPI.generateNetWorthOverTime(accountHistory, 7);
      const last30Days = NetWorthAPI.generateNetWorthOverTime(accountHistory, 30);
      const lastYear = NetWorthAPI.generateNetWorthOverTime(accountHistory, 365);

      return NetWorthOverTime.fromPlain({
        accountId,
        last1Day: last1Day.frame,
        last7Days: last7Days.frame,
        last30Days: last30Days.frame,
        lastYear: lastYear.frame,
        historicalData: NetWorthAPI.snapshotToHistoricalDict(lastYear.snapshot),
      });
    });
  }
}
