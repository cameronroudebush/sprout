import { Account } from "@backend/model/account";
import { AccountHistory } from "@backend/model/account.history";
import { Base } from "@backend/model/base";
import { differenceInDays, eachDayOfInterval, isSameDay, subDays } from "date-fns";
import { cloneDeep } from "lodash";

/** This class represents a point in time of an entity history. */
export class EntityHistoryDataPoint extends Base {
  percentChange?: number;
  valueChange: number;
  /** This is the history for this specific data point */
  history: Map<number, number>;

  constructor(valueChange: number, history: Map<number, number>, percentChange?: number) {
    super();
    this.valueChange = valueChange;
    this.history = history;
    this.percentChange = percentChange;
  }
}

/** This class represents the value of an entity (account, stock, etc.) over time. */
export class EntityHistory extends Base {
  last1Day: EntityHistoryDataPoint;
  last7Days: EntityHistoryDataPoint;
  lastMonth: EntityHistoryDataPoint;
  lastThreeMonths: EntityHistoryDataPoint;
  lastSixMonths: EntityHistoryDataPoint;
  lastYear: EntityHistoryDataPoint;
  allTime: EntityHistoryDataPoint;
  historicalData: Map<number, number>;

  /** Some entity history data may have a connected Id of what it relates to. This could be something like an account Id. */
  connectedId?: string;

  constructor(
    last1Day: EntityHistoryDataPoint,
    last7Days: EntityHistoryDataPoint,
    lastMonth: EntityHistoryDataPoint,
    lastThreeMonths: EntityHistoryDataPoint,
    lastSixMonths: EntityHistoryDataPoint,
    lastYear: EntityHistoryDataPoint,
    allTime: EntityHistoryDataPoint,
    historicalData: Map<number, number>,
  ) {
    super();
    this.last1Day = last1Day;
    this.last7Days = last7Days;
    this.lastMonth = lastMonth;
    this.lastThreeMonths = lastThreeMonths;
    this.lastSixMonths = lastSixMonths;
    this.lastYear = lastYear;
    this.allTime = allTime;
    this.historicalData = historicalData;
  }

  /**
   * Generates net worth over time for the given days. Returns the history snapshot for
   *  those days and the percent change averaged over that time period.
   */
  private static generateNetWorthOverTime(history: AccountHistory[], relatedAccount: Account | undefined, days: number) {
    if (history.length === 0) return { snapshot: [], frame: EntityHistoryDataPoint.fromPlain({ percentChange: 0, valueChange: 0 }) };
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
    const firstNetWorth = netWorthSnapshots[0]?.netWorth;
    const lastNetWorth = netWorthSnapshots[netWorthSnapshots.length - 1]?.netWorth;
    let percentChange: number | null = null;
    let valueChange = 0;
    if (firstNetWorth != null && lastNetWorth != null) {
      percentChange = ((lastNetWorth - firstNetWorth) / firstNetWorth) * 100;
      valueChange = lastNetWorth - firstNetWorth;
    }
    // Check if this is a drain on finances because a decrease is actually an increase
    if (relatedAccount?.isNegativeNetWorth) {
      if (percentChange) percentChange = percentChange * -1;
      valueChange = valueChange * -1;
    }

    const frameHistory = netWorthSnapshots.reduce((acc, item) => {
      acc[item.date.getTime()] = item.netWorth;
      return acc;
    }, {} as any);

    return { snapshot: netWorthSnapshots, frame: EntityHistoryDataPoint.fromPlain({ percentChange, valueChange, history: frameHistory }) };
  }

  /** Given an account history, returns the entity value over time for the given history */
  static getForHistory(history: AccountHistory[], relatedAccount?: Account) {
    // How far back we have data for, total
    const sproutAccountLifetime = differenceInDays(new Date(), history[0]?.time ?? 1);
    const boundCallback = EntityHistory.generateNetWorthOverTime.bind(this, history, relatedAccount);

    const last1Day = boundCallback(1);
    const last7Days = boundCallback(7);
    const lastMonth = boundCallback(30);
    const lastThreeMonths = boundCallback(90);
    const lastSixMonths = boundCallback(180);
    const lastYear = boundCallback(365);
    // Convert the last year of snapshot into a map
    const historicalData = lastYear.snapshot.reduce((acc, curr) => ({ ...acc, [curr.date.getTime()]: curr.netWorth }), {});
    // We must make a separate history so we can show that we started from 0
    const allTimeHistory = cloneDeep(history);
    allTimeHistory.unshift(AccountHistory.fromPlain({ time: subDays(new Date(), sproutAccountLifetime + 1), balance: 0 }));
    const allTime = EntityHistory.generateNetWorthOverTime(allTimeHistory, relatedAccount, sproutAccountLifetime + 1);

    return EntityHistory.fromPlain({
      last1Day: last1Day.frame,
      last7Days: last7Days.frame,
      lastMonth: lastMonth.frame,
      lastThreeMonths: lastThreeMonths.frame,
      lastSixMonths: lastSixMonths.frame,
      lastYear: lastYear.frame,
      allTime: allTime.frame,
      historicalData,
    });
  }
}
