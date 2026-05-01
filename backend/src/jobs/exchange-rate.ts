import { Configuration } from "@backend/config/core";
import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { CurrencyOptions } from "@backend/user/model/user.config.model";
import { Injectable } from "@nestjs/common";
import YahooFinance from "yahoo-finance2";
import { BackgroundJob } from "./base";

/** This class defines a background job that runs in the background to automatically update exchange rates */
@Injectable()
export class ExchangeRateJob extends BackgroundJob<any> {
  constructor() {
    super("exchange-rate", Configuration.server.exchangeRateTime);
  }

  override async start() {
    return super.start(true); // Always check immediately on startup
  }

  protected async update() {
    await this.refreshExchangeRates();
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
      const results = await Promise.all(symbols.map((x) => yf.quoteCombine(x)));
      const newMap = new Map<string, Map<string, number>>();

      results.forEach((quote) => {
        const pair = symbolToPairMap.get(quote.symbol);
        if (!pair || quote.regularMarketPrice === undefined) return;

        const { from, to } = pair;
        const rate = quote.regularMarketPrice;

        // Ensure sub-maps exist
        if (!newMap.has(from)) newMap.set(from, new Map());
        if (!newMap.has(to)) newMap.set(to, new Map());

        // Set direct and inverted rates
        newMap.get(from)!.set(to, rate);
        newMap.get(to)!.set(from, 1 / rate);
      });

      CurrencyHelper.exchangeRates = newMap;
      this.logger.log(`Refresh complete.`);
    } catch (error) {
      this.logger.error("Failed to fetch batched exchange rates", error);
    }
  }
}
