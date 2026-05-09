import { ConfigurationService } from "@backend/config/config.service";
import { Configuration } from "@backend/config/core";
import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { CurrencyOptions } from "@backend/user/model/user.config.model";
import { CACHE_MANAGER, Cache } from "@nestjs/cache-manager";
import { Inject, Injectable } from "@nestjs/common";
import YahooFinance from "yahoo-finance2";
import { BackgroundJob } from "./base";

/** This class defines a background job that runs in the background to automatically update exchange rates */
@Injectable()
export class ExchangeRateJob extends BackgroundJob<any> {
  /** The key we store content under in the cache manager */
  static readonly CACHE_KEY = "exchange-rates";

  /** Locally kept cache to be easily access by {@link CurrencyHelper} */
  static exchangeRates: Record<string, Record<string, number>> = {};

  constructor(
    private readonly configService: ConfigurationService,
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
  ) {
    super("exchange-rate", Configuration.server.exchangeRateTime);
  }

  override async start() {
    return super.start(true); // Always check immediately on startup
  }

  protected async update() {
    const hydrated = await this.updateFromL2();

    // If L2 didn't have it (or it expired), fetch from Yahoo
    if (!hydrated) await this.refreshExchangeRates();
  }

  /** Hydrates {@link CurrencyHelper.exchangeRates} based on the L2 cache content. Returns true if successful. */
  private async updateFromL2(): Promise<boolean> {
    try {
      const cachedRates = await this.cacheManager.get<Record<string, Record<string, number>>>(ExchangeRateJob.CACHE_KEY);

      if (cachedRates && Object.keys(cachedRates).length > 0) {
        ExchangeRateJob.exchangeRates = cachedRates;
        this.logger.log("Successfully synchronized local exchange rates from L2 cache.");
        return true;
      }
      return false;
    } catch (error) {
      this.logger.error("Failed to read exchange rates from L2 cache", error);
      return false;
    }
  }

  /**
   * Generates all required pairs from the {@link CurrencyOptions} enum
   */
  async refreshExchangeRates() {
    const yf = new YahooFinance({ suppressNotices: ["yahooSurvey"] });
    this.logger.log("Starting exchange rate refresh...");

    const allCurrencies = Object.values(CurrencyOptions);
    const symbols: string[] = [];
    const symbolToPairMap = new Map<string, { from: string; to: string }>();
    const processedPairs = new Set<string>();

    for (const from of allCurrencies) {
      for (const to of allCurrencies) {
        if (from === to) continue;
        const pairKey = [from, to].sort().join("-");
        if (!processedPairs.has(pairKey)) {
          const symbol = `${from}${to}=X`;
          symbols.push(symbol);
          symbolToPairMap.set(symbol, { from, to });
          processedPairs.add(pairKey);
        }
      }
    }

    if (symbols.length === 0) return;

    try {
      const results = await Promise.all(symbols.map((x) => yf.quote(x)));
      const newRates: Record<string, Record<string, number>> = {};

      results.forEach((quote) => {
        const pair = symbolToPairMap.get(quote.symbol);
        if (!pair || quote.regularMarketPrice === undefined) return;

        const { from, to } = pair;
        const rate = quote.regularMarketPrice;

        // Ensure sub-objects exist
        if (!newRates[from]) newRates[from] = {};
        if (!newRates[to]) newRates[to] = {};

        // Set direct and inverted rates
        newRates[from][to] = rate;
        newRates[to][from] = 1 / rate;
      });

      // Update our cache
      ExchangeRateJob.exchangeRates = newRates;
      const ttl = await this.configService.convertCronToMilliseconds(Configuration.server.exchangeRateTime, 300000);
      await this.cacheManager.set(ExchangeRateJob.CACHE_KEY, newRates, ttl);
      this.logger.log(`Refresh complete.`);
    } catch (error) {
      this.logger.error("Failed to fetch batched exchange rates", error);
    }
  }
}
