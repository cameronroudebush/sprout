import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { HoldingHistory } from "@backend/holding/model/holding.history.model";
import { Holding } from "@backend/holding/model/holding.model";
import { EntityHistory, EntityHistoryDataPoint, HistoricalDataPoint } from "@backend/net-worth/model/api/entity.history.dto";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";
import { differenceInDays, eachDayOfInterval, format, isSameDay, startOfDay, subDays } from "date-fns";

/** Type that represents our net worth at a specific date */
type NetWorthSnapshot = { date: Date; netWorth: number };

@Injectable()
export class NetWorthService {
  constructor() {}

  /** Aggregates ALL accounts for a user into a single Net Worth timeline. */
  async getNetWorthSummary(user: User) {
    const history = await this.getAccountHistoryForUser(user);
    return this.getForHistory(history);
  }

  /** Fetches and calculates net worth for all of a user's accounts. Excludes timeline. */
  async getNetWorthByAccounts(user: User) {
    const [accounts, histories] = await Promise.all([Account.getForUser(user), this.getAccountHistoryForUser(user, 1)]);
    return this.processEntityGroups(
      accounts,
      histories,
      (h) => h.account.id,
      (a) => a,
    );
  }

  /** Fetches and calculates history for all holdings associated to a user. */
  async getHistoryForHoldings(account: Account) {
    const [holdings, histories] = await Promise.all([Holding.getForAccount(account), this.getHoldingHistoryForUser(account, 1)]);
    return this.processEntityGroups(holdings, histories, (h) => h.holding.id, undefined);
  }

  /** Fetches and calculates history for only the given holding. */
  async getHistoryForHolding(holding: Holding) {
    const history = await this.getHoldingHistoryForUser(holding.account, 1, holding);
    return this.getForHistory(history);
  }

  /** Returns the net worth of a specific account */
  async getNetWorthByAccount(user: User, account: Account) {
    const rawHistory = await this.getAccountHistoryForUser(user, 1, account);
    return this.getForHistory(rawHistory, account);
  }

  /** Fetches the AccountHistory from the database utilizing QueryBuilder for efficiency. Sorts by time. */
  private async getAccountHistoryForUser(user: User, years = 1, account?: Account): Promise<AccountHistory[]> {
    const query = AccountHistory.getRepository()
      .createQueryBuilder("history")
      .innerJoinAndSelect("history.account", "account")
      .where("account.userId = :userId", { userId: user.id })
      .andWhere("history.time > :startDate", { startDate: subDays(new Date(), years * 365) })
      .orderBy("history.time", "ASC");
    if (account) query.andWhere("account.id = :accountId", { accountId: account.id });
    return await query.getMany();
  }

  /** Fetches the HoldingHistory from the database utilizing QueryBuilder for efficiency. Sorts by time. */
  private async getHoldingHistoryForUser(account: Account, years = 1, holding?: Holding): Promise<HoldingHistory[]> {
    const query = HoldingHistory.getRepository()
      .createQueryBuilder("history")
      .innerJoinAndSelect("history.holding", "holding")
      .where("holding.accountId = :accountId", { accountId: account.id })
      .andWhere("history.time > :startDate", { startDate: subDays(new Date(), years * 365) })
      .orderBy("history.time", "ASC");
    if (holding) query.andWhere("holding.id = :holdingId", { holdingId: holding.id });
    return await query.getMany();
  }

  /**
   * Generic method to Group History -> Match to Entity -> Calculate Stats
   */
  private processEntityGroups<TEntity extends { id: string }, THistory extends AccountHistory | HoldingHistory>(
    entities: TEntity[],
    histories: THistory[],
    groupKeySelector: (h: THistory) => string,
    accountSelector?: (e: TEntity) => Account,
  ) {
    const historyMap = new Map<string, THistory[]>();
    for (const h of histories) {
      const key = groupKeySelector(h);
      if (!historyMap.has(key)) historyMap.set(key, []);
      historyMap.get(key)!.push(h);
    }

    return entities.map((entity) => {
      const entityHistory = historyMap.get(entity.id) || [];
      const relatedAccount = accountSelector ? accountSelector(entity) : undefined;
      const stats = this.getForHistory(entityHistory, relatedAccount);
      // Attach the ID for the frontend
      stats.history.connectedId = entity.id;
      return stats;
    });
  }

  /**
   * Main Calculator for generating a history representation for history within the database
   * 1. Dedupes entries (taking only the latest sync per account per day)
   * 2. Aggregates totals
   * 3. Generates timeline (if requested)
   */
  private getForHistory<T extends AccountHistory | HoldingHistory>(rawHistory: T[], relatedAccount?: Account) {
    if (!rawHistory || rawHistory.length === 0) return { history: EntityHistory.plain, timeline: () => [] };

    // Helper to extract value based on type
    const getValue = (h: T) => (h instanceof AccountHistory ? h.balance : h.marketValue);

    // Helper to get Source ID (Account ID or Holding ID) to distinguish data sources
    const getSourceId = (h: T) => {
      if (h instanceof AccountHistory) return h.account?.id || (h as any).accountId;
      if (h instanceof HoldingHistory) return h.holding?.id || (h as any).holdingId;
      return "unknown";
    };

    // DEDUPLICATION
    // We must ensure we only take the LAST entry for a specific Account/Holding on a specific Day.
    const uniqueDailyValues = new Map<string, number>();

    for (const entry of rawHistory) {
      const dateKey = format(entry.time, "yyyy-MM-dd");
      const sourceId = getSourceId(entry);
      const uniqueKey = `${sourceId}|${dateKey}`;

      let val = getValue(entry);

      // Overwrite previous value for this specific account on this specific day.
      // Since rawHistory is sorted ASC, the last value set here is the end-of-day value.
      uniqueDailyValues.set(uniqueKey, val);
    }

    // AGGREGATION
    // Now sum up all unique account values for each day into a single daily total.
    const dailyTotals = new Map<string, number>();
    for (const [key, val] of uniqueDailyValues) {
      const [_, dateStr] = key.split("|");
      const currentTotal = dailyTotals.get(dateStr!) || 0;
      dailyTotals.set(dateStr!, currentTotal + val);
    }

    // TIMELINE GENERATION
    const today = startOfDay(new Date());
    const firstHistoryDate = startOfDay(rawHistory[0]!.time);
    const totalDaysDiff = differenceInDays(today, firstHistoryDate);
    const daysToGenerate = Math.max(totalDaysDiff, 365);
    const startDate = subDays(today, daysToGenerate);

    const dailySnapshots: NetWorthSnapshot[] = [];
    let currentNetWorth = 0;

    // Initialize start value
    const startKey = format(startDate, "yyyy-MM-dd");
    if (dailyTotals.has(startKey)) currentNetWorth = dailyTotals.get(startKey)!;

    const allDays = eachDayOfInterval({ start: startDate, end: today });

    for (const day of allDays) {
      const key = format(day, "yyyy-MM-dd");
      // If we have data for this day, update our "current" known value
      if (dailyTotals.has(key)) currentNetWorth = dailyTotals.get(key)!;
      dailySnapshots.push({ date: day, netWorth: currentNetWorth });
    }

    // FRAME EXTRACTION
    const getFrame = (daysBack: number): EntityHistoryDataPoint => {
      const index = dailySnapshots.length - 1 - daysBack;
      const targetSnapshot = dailySnapshots[index < 0 ? 0 : index];
      return this.calculateChange(dailySnapshots, targetSnapshot?.date || subDays(today, daysBack), relatedAccount);
    };

    const allTimeFrame = this.calculateChange(dailySnapshots, firstHistoryDate, relatedAccount);

    return {
      /** The entity history of the various time frames */
      history: new EntityHistory(getFrame(1), getFrame(7), getFrame(30), getFrame(90), getFrame(180), getFrame(365), allTimeFrame),
      /**
       * A historical representation of a timeline. Potentially expensive to generate
       * @param maxPoints The maximum number of data points we want to display
       */
      timeline: (maxPoints = 500) => {
        // If we have fewer points than the max, return everything
        if (dailySnapshots.length <= maxPoints) return dailySnapshots.map((x) => new HistoricalDataPoint(x.date, x.netWorth));
        // Downsample: Calculate a step size to evenly skip items
        const step = dailySnapshots.length / maxPoints;
        const sampledData = [];
        for (let i = 0; i < maxPoints; i++) {
          const index = Math.floor(i * step);
          if (index < dailySnapshots.length) {
            const x = dailySnapshots[index];
            sampledData.push(new HistoricalDataPoint(x!.date, x!.netWorth));
          }
        }
        // ALWAYS ensure the very last data point (Today) is included so the chart ends correctly
        const lastOriginal = dailySnapshots[dailySnapshots.length - 1];
        const lastSampled = sampledData[sampledData.length - 1];
        if (lastSampled && lastSampled.date.getTime() !== lastOriginal!.date.getTime())
          sampledData.push(new HistoricalDataPoint(lastOriginal!.date, lastOriginal!.netWorth));
        return sampledData;
      },
    };
  }

  /** Standardized calc for determining value and percentage change for snapshots of data */
  private calculateChange(snapshots: NetWorthSnapshot[], startDate: Date, relatedAccount?: Account) {
    const todaySnapshot = snapshots[snapshots.length - 1];

    // Find the snapshot closest to the start date requested
    let startSnapshot = snapshots.find((x) => isSameDay(x.date, startDate));

    // Fallback: if exact date not found (rare due to gap filling), use the first available
    if (!startSnapshot) startSnapshot = snapshots[0];

    const endVal = todaySnapshot?.netWorth ?? 0;
    const startVal = startSnapshot?.netWorth ?? 0;

    let valueChange = endVal - startVal;
    let percentChange = 0;

    if (startVal !== 0) percentChange = (valueChange / Math.abs(startVal)) * 100;
    else if (endVal !== 0)
      // Previous value was 0, new is not. Treat as 100% or -100% change
      percentChange = endVal > 0 ? 100 : -100;

    // Invert logic for liability accounts (negative net worth accounts)
    if (relatedAccount?.isNegativeNetWorth) {
      percentChange *= -1;
      valueChange *= -1;
    }

    // Cleanup data
    if (isNaN(valueChange)) valueChange = 0;
    if (isNaN(percentChange)) percentChange = 0;

    return new EntityHistoryDataPoint(valueChange, percentChange, startDate);
  }
}
