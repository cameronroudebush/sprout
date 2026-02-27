import { Account } from "@backend/account/model/account.model";
import { MarketIndexDto } from "@backend/holding/model/api/mark.index.dto";
import { Holding } from "@backend/holding/model/holding.model";
import { EntityHistory } from "@backend/net-worth/model/api/entity.history.dto";
import { NetWorthService } from "@backend/net-worth/net-worth.service";
import { CACHE_MANAGER } from "@nestjs/cache-manager";
import { HttpException, HttpStatus, Inject, Injectable } from "@nestjs/common";
import { Cache } from "cache-manager";
import YahooFinance from "yahoo-finance2";

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
   * @param ttlMs Cache timeout in milliseconds (default: 5 minutes)
   */
  async getLiveHoldingPrices(symbols: string[], ttlMs: number = 5 * 60 * 1000): Promise<MarketIndexDto[]> {
    try {
      const finalResults: MarketIndexDto[] = [];
      const missingSymbols: string[] = [];

      // Check the cache for each symbol to avoid unnecessary batch queries
      for (const symbol of symbols) {
        const cacheKey = `quote:${symbol}`;
        const cachedQuote = await this.cacheManager.get<MarketIndexDto>(cacheKey);
        if (cachedQuote) finalResults.push(cachedQuote);
        else missingSymbols.push(symbol);
      }

      // Query Yahoo Finance only for the symbols that weren't cached
      if (missingSymbols.length > 0) {
        const rawQuotes = await this.yf.quote(missingSymbols);

        for (const quote of rawQuotes) {
          const dto = new MarketIndexDto(quote);
          finalResults.push(dto);
          // Cache new data
          const cacheKey = `quote:${quote.symbol}`;
          await this.cacheManager.set(cacheKey, dto, ttlMs);
        }
      }

      return finalResults;
    } catch (error) {
      throw new HttpException("Failed to fetch holding prices", HttpStatus.SERVICE_UNAVAILABLE);
    }
  }

  /** Fetches the live data for major indices. */
  async getMajorIndices(symbols = ["^GSPC", "^DJI", "^IXIC"], ttlMs?: number) {
    return (await this.getLiveHoldingPrices(symbols, ttlMs)).map((x) => {
      // Adjust their names
      if (x.symbol === "^GSPC") x.name = "S&P 500";
      else if (x.symbol === "^DJI") x.name = "DIJA";
      else if (x.symbol === "^IXIC") x.name = "NASDAQ";
      return x;
    });
  }
}
