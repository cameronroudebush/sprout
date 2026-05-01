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

  /** Returns the total net worth for a given user using the database to calculate the math */
  async getTotalSummary(user: User) {
    const accounts = Account.convertListToTargetCurrency(await Account.find({ where: { user: { id: user.id } } }), user);
    return accounts.reduce((a, b) => a + b.balance, 0);
  }

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
    const history = await query.getMany();

    // Add "live" state which is today's data
    if (account) this.appendLiveAccountEntry(history, account);
    else {
      const seenAccounts = new Set<string>();
      for (let i = history.length - 1; i >= 0; i--) {
        const entry = history[i]!;
        if (!seenAccounts.has(entry.account.id)) {
          this.appendLiveAccountEntry(history, entry.account);
          seenAccounts.add(entry.account.id);
        }
      }
    }
    return AccountHistory.convertListToTargetCurrency(history, user);
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
    const history = await query.getMany();

    // Add "live" state which is today's data
    if (holding) this.appendLiveHoldingEntry(history, holding);
    else {
      const seenHoldings = new Set<string>();
      for (let i = history.length - 1; i >= 0; i--) {
        const entry = history[i]!;
        if (!seenHoldings.has(entry.holding.id)) {
          this.appendLiveHoldingEntry(history, entry.holding);
          seenHoldings.add(entry.holding.id);
        }
      }
    }
    return HoldingHistory.convertListToTargetCurrency(history, account.user);
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

    // Group all raw data by date so we can process the timeline day-by-day
    const historyByDate = new Map<string, T[]>();
    for (const entry of rawHistory) {
      const dateKey = format(entry.time, "yyyy-MM-dd");
      if (!historyByDate.has(dateKey)) historyByDate.set(dateKey, []);
      historyByDate.get(dateKey)!.push(entry);
    }

    // Setup timeline boundaries
    const today = startOfDay(new Date());
    const firstHistoryDate = startOfDay(rawHistory[0]!.time);
    const totalDaysDiff = differenceInDays(today, firstHistoryDate);
    const daysToGenerate = Math.max(totalDaysDiff, 365);
    const startDate = subDays(today, daysToGenerate);
    const allDays = eachDayOfInterval({ start: startDate, end: today });

    const dailySnapshots: NetWorthSnapshot[] = [];

    // Keep track of the latest known value for EVERY account/holding.
    const lastKnownValuesBySource = new Map<string, number>();

    for (const day of allDays) {
      const dateKey = format(day, "yyyy-MM-dd");
      const entriesForDay = historyByDate.get(dateKey) || [];

      // Update the "last known" map with any new data found on this specific day
      for (const entry of entriesForDay) lastKnownValuesBySource.set(getSourceId(entry), getValue(entry));

      // Calculate Total Net Worth for today by summing the last known value of ALL sources
      let dayTotal = 0;
      for (const val of lastKnownValuesBySource.values()) dayTotal += val;

      dailySnapshots.push({ date: day, netWorth: dayTotal });
    }

    // Time frame extraction
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
        if (sampledData[sampledData.length - 1]?.date.getTime() !== lastOriginal!.date.getTime())
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

  /** Pushes a synthetic "Now" entry based on the live Account entity */
  private appendLiveAccountEntry(history: AccountHistory[], account: Account) {
    const liveEntry = new AccountHistory(account, new Date(), account.balance, account.balance);
    history.push(liveEntry);
  }

  /** Pushes a synthetic "Now" entry based on the live Holding entity */
  private appendLiveHoldingEntry(history: HoldingHistory[], holding: Holding) {
    const liveEntry = new HoldingHistory();
    liveEntry.time = new Date();
    liveEntry.marketValue = holding.marketValue;
    liveEntry.holding = holding;
    history.push(liveEntry);
  }
}
