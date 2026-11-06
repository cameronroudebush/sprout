import { Account } from "@backend/account/model/account.model";
import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { MajorIndexTimelineDto, MajorIndexTimelinePoint } from "@backend/holding/model/api/major.index.timeline.dto";
import { MarketIndexDto, MarketQuoteType, MarketState } from "@backend/holding/model/api/mark.index.dto";
import { PortfolioSummaryDto } from "@backend/holding/model/api/portfolio.summary.dto";
import { Holding } from "@backend/holding/model/holding.model";
import { EntityHistory } from "@backend/net-worth/model/api/entity.history.dto";
import { NetWorthService } from "@backend/net-worth/net-worth.service";
import { User } from "@backend/user/model/user.model";
import { CACHE_MANAGER } from "@nestjs/cache-manager";
import { HttpException, HttpStatus, Inject, Injectable } from "@nestjs/common";
import { type Cache } from "cache-manager";
import { Not } from "typeorm";
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
  private readonly yf = new YahooFinance({ suppressNotices: ["yahooSurvey"], validation: { logErrors: false } });
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
            } catch (e) {
              return { symbol, summary: null };
            }
          }),
        );

        // Concurrent Cache Update
        await Promise.all(
          summaries.map(async ({ symbol, summary }) => {
            if (!summary || !summary.price) {
              const unknownDto = new MarketIndexDto({
                symbol,
                shortName: symbol,
                quoteType: MarketQuoteType.INVALID,
                regularMarketPrice: null,
                regularMarketTime: new Date().toISOString(),
              });
              await this.cacheManager.set(`quote:${symbol}`, undefined, ttlMs);
              finalResults.push(unknownDto);
              return;
            }
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

  /** Calculates a user's total portfolio value and today's movement. */
  async getPortfolioSummary(user: User): Promise<PortfolioSummaryDto> {
    const holdings = await Holding.find({
      where: { account: { user: { id: user.id } }, shares: Not(0) },
    });
    const symbols = [...new Set([...holdings.map((holding) => holding.symbol), "^GSPC"])];
    const quotes = await this.getLiveHoldingPrices(symbols);
    const quoteBySymbol = new Map(quotes.map((quote) => [quote.symbol, quote]));
    const targetCurrency = user.config?.currency ?? "USD";
    // Mutual-fund quotes can say CLOSED while the exchange is trading; use an index for session state.
    const marketIndexQuote = quoteBySymbol.get("^GSPC");
    const marketIsOpen = marketIndexQuote?.marketState === MarketState.REGULAR;

    let totalValue = 0;
    let pricedValue = 0;
    let dayChange = 0;
    let hasUnpricedHoldings = false;
    for (const holding of holdings) {
      const quote = quoteBySymbol.get(holding.symbol);
      if (quote && quote.type !== MarketQuoteType.INVALID && quote.price > 0) {
        const sourceCurrency = quote.currency ?? holding.currency;
        const currentValue = CurrencyHelper.convert(quote.price * holding.shares, sourceCurrency, targetCurrency);
        totalValue += currentValue;
        const mutualFundMarketIsClosed =
          quote.marketState === MarketState.CLOSED ||
          quote.marketState === MarketState.POST ||
          quote.marketState === MarketState.POSTPOST ||
          quote.marketState === MarketState.PRE ||
          quote.marketState === MarketState.PREPRE;
        const mutualFundIsUnpriced = quote.type === MarketQuoteType.MUTUALFUND && (marketIsOpen || !mutualFundMarketIsClosed || !quote.hasMarketTimestamp);
        if (mutualFundIsUnpriced) {
          hasUnpricedHoldings = true;
          continue;
        }

        pricedValue += currentValue;
        dayChange += CurrencyHelper.convert((quote.change ?? 0) * holding.shares, sourceCurrency, targetCurrency);
        continue;
      }

      const storedValue = CurrencyHelper.convert(holding.marketValue, holding.currency, targetCurrency);
      totalValue += storedValue;
      pricedValue += storedValue;
      const closePrice = Number(holding.extra?.["closePrice"]);
      if (closePrice > 0 && holding.shares !== 0) {
        const estimatedChange = holding.marketValue - closePrice * holding.shares;
        dayChange += CurrencyHelper.convert(estimatedChange, holding.currency, targetCurrency);
      }
    }

    const previousValue = pricedValue - dayChange;
    const dayChangePercent = previousValue !== 0 ? (dayChange / Math.abs(previousValue)) * 100 : 0;
    return new PortfolioSummaryDto({
      totalValue,
      dayChange,
      dayChangePercent: Number.isFinite(dayChangePercent) ? dayChangePercent : 0,
      hasUnpricedHoldings,
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
        const indexConfig = MAJOR_INDICES[symbol]!;
        const name = indexConfig.name;
        const color = indexConfig.color;

        const timeline: MajorIndexTimelinePoint[] = [];
        if (rawChart && Array.isArray(rawChart.quotes) && rawChart.quotes.length > 0) {
          const validQuotes = rawChart.quotes.filter((q) => q && q.date && q.close !== undefined && q.close !== null);
          if (validQuotes.length > 0) {
            // Track the previous day's price to calculate day-over-day change
            let previousPrice = validQuotes[0]!.close as number;
            for (let i = 0; i < validQuotes.length; i++) {
              const quote = validQuotes[i]!;
              const price = quote.close as number;
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
