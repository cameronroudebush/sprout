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
   * Filters out outliers from an array of net worth snapshots using the IQR method.
   * @param snapshots The original array of data points.
   * @returns A new array with outliers removed.
   */
  static removeOutliersIQR(snapshots: Array<{ date: Date; netWorth: number }>): Array<{ date: Date; netWorth: number }> {
    // Can't reliably detect outliers with too few data points, so return the original array.
    if (snapshots.length < 4) {
      return snapshots;
    }

    // Get a sorted array of just the net worth values
    const netWorths = snapshots.map((s) => s.netWorth).sort((a, b) => a - b);

    // Calculate Q1 (25th percentile) and Q3 (75th percentile)
    const q1Index = Math.floor(netWorths.length * 0.25);
    const q3Index = Math.floor(netWorths.length * 0.75);
    const q1 = netWorths[q1Index]!;
    const q3 = netWorths[q3Index]!;

    // Calculate the Interquartile Range (IQR)
    const iqr = q3 - q1;

    // Define the upper and lower bounds for what is considered a non-outlier
    const lowerBound = q1 - 1.5 * iqr;
    const upperBound = q3 + 1.5 * iqr;

    // Return a new array containing only the snapshots within the valid bounds
    return snapshots.filter((snapshot) => snapshot.netWorth >= lowerBound && snapshot.netWorth <= upperBound);
  }

  /**
   * Generates net worth over time for the given days. Returns the history snapshot for
   * those days and the percent change averaged over that time period.
   */
  private static generateNetWorthOverTime(history: AccountHistory[], relatedAccount: Account | undefined, days: number) {
    if (history.length === 0) return { snapshot: [], frame: EntityHistoryDataPoint.fromPlain({ percentChange: 0, valueChange: 0 }) };
    const today = new Date();

    const netWorthSnapshots: Array<{ date: Date; netWorth: number }> = [];

    // Populate snapshot for every of the last N days
    days -= 1; // We want to make sure to only include the correct amount of days in our calculation
    const daysInArray = eachDayOfInterval({ start: subDays(today, days), end: today });
    for (const day of daysInArray) {
      const historyForDay = history.filter((x) => isSameDay(x.time, day));
      let netWorth = historyForDay.reduce((prev, curr) => (prev += curr.balance), 0);

      // If there's no data for the current day, use the net worth from the most recent previous day
      if (historyForDay.length === 0 && netWorthSnapshots.length > 0) {
        netWorth = netWorthSnapshots[netWorthSnapshots.length - 1]?.netWorth ?? 0;
      } else if (historyForDay.length === 0 && netWorthSnapshots.length === 0 && days === 1) {
        // No previous data, try further back if this is a small days of change
        const furtherHistory = history.filter((x) => isSameDay(x.time, subDays(day, 1)));
        netWorth = furtherHistory.reduce((prev, curr) => (prev += curr.balance), 0);
      } else if (historyForDay.length === 0 && daysInArray.length > 7) {
        // If there's no data and it's not within the last 7 days, skip this day to avoid skewing with zero-value days
        continue;
      }

      netWorthSnapshots.push({ date: day, netWorth });
    }

    // const filteredSnapshots = this.removeOutliersIQR(netWorthSnapshots);
    const filteredSnapshots = netWorthSnapshots;

    const firstNetWorth = filteredSnapshots[0]?.netWorth;
    const lastNetWorth = filteredSnapshots[filteredSnapshots.length - 1]?.netWorth;

    let percentChange: number | null = null;
    let valueChange = 0;
    if (firstNetWorth != null && lastNetWorth != null && firstNetWorth !== 0) {
      // Note: Changed denominator to firstNetWorth for a standard percentage change calculation
      percentChange = ((lastNetWorth - firstNetWorth) / Math.abs(firstNetWorth)) * 100;
      valueChange = lastNetWorth - firstNetWorth;
    } else if (firstNetWorth === 0 && lastNetWorth != null) {
      percentChange = lastNetWorth > 0 ? 100 : lastNetWorth < 0 ? -100 : 0; // or Infinity, depending on desired behavior
      valueChange = lastNetWorth;
    }

    // Check if this is a drain on finances because a decrease is actually an increase
    if (relatedAccount?.isNegativeNetWorth) {
      if (percentChange) percentChange = percentChange * -1;
      valueChange = valueChange * -1;
    }

    const frameHistory = filteredSnapshots.reduce((acc, item) => {
      acc[item.date.getTime()] = item.netWorth;
      return acc;
    }, {} as any);

    return { snapshot: filteredSnapshots, frame: EntityHistoryDataPoint.fromPlain({ percentChange, valueChange, history: frameHistory }) };
  }

  /** Given an account history, returns the entity value over time for the given history */
  static getForHistory(history: AccountHistory[], relatedAccount?: Account) {
    // How far back we have data for, total
    const sproutAccountLifetime = differenceInDays(new Date(), history[0]?.time ?? 1);
    const boundCallback = EntityHistory.generateNetWorthOverTime.bind(this, history, relatedAccount);

    const last1Day = boundCallback(2);
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
