import { Account } from "@backend/account/model/account.model";
import { MajorIndexTimelineDto, MajorIndexTimelinePoint } from "@backend/holding/model/api/major.index.timeline.dto";
import { MarketIndexDto } from "@backend/holding/model/api/mark.index.dto";
import { Holding } from "@backend/holding/model/holding.model";
import { EntityHistory } from "@backend/net-worth/model/api/entity.history.dto";
import { NetWorthService } from "@backend/net-worth/net-worth.service";
import { CACHE_MANAGER } from "@nestjs/cache-manager";
import { HttpException, HttpStatus, Inject, Injectable } from "@nestjs/common";
import { Cache } from "cache-manager";
import YahooFinance from "yahoo-finance2";

const MAJOR_INDICES: Record<string, { name: string; color: string }> = {
  "^GSPC": { name: "S&P 500", color: "#2196F3" }, // Blue
  "^DJI": { name: "DJIA", color: "#FF9800" }, // Orange
  "^IXIC": { name: "NASDAQ", color: "#9C27B0" }, // Purple
};

/**
 * This service provides holdings common functions
 */
@Injectable()
export class HoldingService {
  private readonly yf = new YahooFinance({ suppressNotices: ["yahooSurvey"] });
  constructor(
    private readonly netWorthService: NetWorthService,
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
  ) {}

  /** Generates the holding history, per holding, for all holdings of the given account. Does not include timeline */
  async getHistoryForAccount(account: Account): Promise<EntityHistory[]> {
    return (await this.netWorthService.getHistoryForHoldings(account)).map((x) => x.history);
  }

  /** Generates the holding history for an individual holding, only including the timeline. */
  async getTimelineForHolding(holding: Holding) {
    return await this.netWorthService.getHistoryForHolding(holding);
  }

  /**
   * Fetches live prices for a given array of symbols.
   * Checks the cache for each symbol individually before querying Yahoo Finance for the missing ones.
   * @param symbols Array of ticker symbols to fetch
   * @param ttlMs Cache timeout in milliseconds (default: 15 minutes)
   */
  async getLiveHoldingPrices(symbols: string[], ttlMs: number = 15 * 60 * 1000): Promise<MarketIndexDto[]> {
    try {
      const uniqueSymbols = [...new Set(symbols)];

      // Concurrent Cache Lookup
      const cacheLookups = await Promise.all(uniqueSymbols.map((s) => this.cacheManager.get<MarketIndexDto>(`quote:${s}`)));

      const finalResults: MarketIndexDto[] = [];
      const missingSymbols: string[] = [];

      // Sort results into "Found" and "Missing"
      uniqueSymbols.forEach((symbol, index) => {
        const cached = cacheLookups[index];
        if (cached) finalResults.push(cached);
        else missingSymbols.push(symbol);
      });

      // Batch Request for Missing Symbols
      if (missingSymbols.length > 0) {
        const summaries = await Promise.all(
          missingSymbols.map(async (symbol) => {
            try {
              const summary = await this.yf.quoteSummary(symbol, {
                modules: ["price", "summaryDetail"],
              });
              return { symbol, summary };
            } catch {
              return { symbol, summary: null };
            }
          }),
        );

        // Concurrent Cache Update
        await Promise.all(
          summaries.map(async ({ symbol, summary }) => {
            if (!summary || !summary.price) return;
            let rawYield = summary.summaryDetail?.dividendYield ?? summary.summaryDetail?.yield ?? 0.0;
            const isMutualFund = summary.price.quoteType === "MUTUALFUND";

            if (isMutualFund) {
              try {
                const today = new Date();
                const oneYearAgo = new Date();
                oneYearAgo.setFullYear(today.getFullYear() - 1);
                const chartEvents = await this.yf.chart(symbol, {
                  period1: oneYearAgo,
                  period2: today,
                  interval: "1d",
                });
                const historicalDividends = chartEvents.events?.dividends;
                if (historicalDividends && historicalDividends.length > 0) {
                  const totalCashDistributed = historicalDividends.reduce((sum, evt) => sum + (evt.amount ?? 0), 0);
                  const currentPrice = summary.price.regularMarketPrice;
                  if (currentPrice && currentPrice > 0) {
                    const historicalYieldCalculated = totalCashDistributed / currentPrice;
                    if (historicalYieldCalculated > rawYield) {
                      rawYield = historicalYieldCalculated;
                    }
                  }
                }
              } catch {}
            }
            const combinedPayload = {
              ...summary.price,
              ...summary.summaryDetail,
              symbol: summary.price.symbol ?? symbol,
              shortName: summary.price.shortName || summary.price.regularMarketSource,
              dividendYield: rawYield ? rawYield * 100 : 0.0,
            };
            const dto = new MarketIndexDto(combinedPayload);
            finalResults.push(dto);

            // Cache the result
            await this.cacheManager.set(`quote:${dto.symbol}`, dto, ttlMs);
          }),
        );
      }

      return finalResults;
    } catch (error) {
      throw new HttpException("Service Unavailable", HttpStatus.SERVICE_UNAVAILABLE);
    }
  }

  /** Fetches the live data for major indices. */
  async getMajorIndices(ttlMs?: number) {
    return (await this.getLiveHoldingPrices(Object.keys(MAJOR_INDICES), ttlMs)).map((x) => {
      x.name = MAJOR_INDICES[x.symbol]?.name ?? x.symbol;
      return x;
    });
  }

  /**
   * Fetches the 7-day historical performance timeline for the Big Three market indices.
   */
  async getMajorIndicesTimeline(ttlMs: number = 60 * 60 * 1000): Promise<MajorIndexTimelineDto[]> {
    const symbols = Object.keys(MAJOR_INDICES);
    const cacheKey = "holding:major:timeline:7d";
    const cachedData = await this.cacheManager.get<any[]>(cacheKey);
    if (cachedData) return cachedData;

    try {
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - 7);

      // Fetch all three indices in a concurrent batch operation
      const historicalResults = await Promise.all(
        symbols.map((symbol) =>
          this.yf
            .chart(symbol, {
              period1: startDate,
              interval: "1d",
            })
            .catch(() => null),
        ),
      );

      const results = symbols.map((symbol, index) => {
        const rawChart = historicalResults[index];
        const indexConfig = MAJOR_INDICES[symbol];
        const name = indexConfig?.name ?? symbol;
        const color = indexConfig?.color ?? "#888888";

        const timeline: MajorIndexTimelinePoint[] = [];
        if (rawChart && Array.isArray(rawChart.quotes) && rawChart.quotes.length > 0) {
          const validQuotes = rawChart.quotes.filter((q) => q && q.date && q.close !== undefined && q.close !== null);
          if (validQuotes.length > 0) {
            // Track the previous day's price to calculate day-over-day change
            let previousPrice = validQuotes[0]?.close ?? 0;
            for (let i = 0; i < validQuotes.length; i++) {
              const quote = validQuotes[i];
              if (!quote) continue;
              const price = quote.close ?? 0;
              let changePercent = 0.0;
              if (i > 0 && previousPrice > 0) changePercent = ((price - previousPrice) / previousPrice) * 100;
              timeline.push({
                date: new Date(quote.date),
                value: price,
                changePercent: parseFloat(changePercent.toFixed(4)),
              });
              previousPrice = price;
            }
          }
        }
        return new MajorIndexTimelineDto({ symbol, name, color, timeline });
      });

      await this.cacheManager.set(cacheKey, results, ttlMs);
      return results;
    } catch (error) {
      throw new HttpException("Failed to retrieve market history timeline", HttpStatus.SERVICE_UNAVAILABLE);
    }
  }
}
