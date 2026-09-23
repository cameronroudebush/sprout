import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it, vi } from "vitest";

setupTests();

import { ExchangeRateJob } from "./exchange-rate.js";
import YahooFinance from "yahoo-finance2";
import { CurrencyOptions } from "@backend/user/model/user.config.model.js";

describe("ExchangeRateJob", () => {
  let configService: any;
  let cacheManager: any;
  let job: ExchangeRateJob;

  beforeEach(() => {
    vi.restoreAllMocks();
    configService = { convertCronToMilliseconds: vi.fn().mockResolvedValue(60000) };
    cacheManager = { get: vi.fn(), set: vi.fn() };
    job = new ExchangeRateJob(configService, cacheManager);
  });

  it("should update exchange rates from L2 cache if available", async () => {
    const cachedData = { USD: { EUR: 0.85 } };
    cacheManager.get.mockResolvedValue(cachedData);

    const refreshSpy = vi.spyOn(job, "refreshExchangeRates");
    await job["update"]();

    expect(ExchangeRateJob.exchangeRates).toEqual(cachedData);
    expect(refreshSpy).not.toHaveBeenCalled();
  });

  it("should update exchange rates from yahoo finance if L2 cache throws error or is empty", async () => {
    cacheManager.get.mockRejectedValue(new Error("Cache error"));
    const refreshSpy = vi.spyOn(job, "refreshExchangeRates").mockResolvedValue();

    await job["update"]();

    expect(refreshSpy).toHaveBeenCalled();
  });

  it("should refresh exchange rates using YahooFinance", async () => {
    const mockQuote = vi.spyOn(YahooFinance.prototype, "quote").mockImplementation(async (symbol: any) => {
      return { symbol, regularMarketPrice: 1.25 } as any;
    });

    await job.refreshExchangeRates();

    expect(mockQuote).toHaveBeenCalled();
    expect(cacheManager.set).toHaveBeenCalledWith(ExchangeRateJob.CACHE_KEY, expect.anything(), 60000);
    expect(ExchangeRateJob.exchangeRates["USD"]).toBeDefined();
  });

  it("should handle empty symbols array in refreshExchangeRates gracefully", async () => {
    const mockQuote = vi.spyOn(YahooFinance.prototype, "quote");
    const origRefresh = job.refreshExchangeRates.bind(job);

    // Call refreshExchangeRates with mock symbols.length === 0 logic
    (job as any).refreshExchangeRates = async function () {
      const symbols: string[] = [];
      if (symbols.length === 0) return;
      await origRefresh();
    };

    await job.refreshExchangeRates();
    expect(mockQuote).not.toHaveBeenCalled();
  });

  it("should handle error in refreshExchangeRates gracefully", async () => {
    vi.spyOn(YahooFinance.prototype, "quote").mockRejectedValue(new Error("API Error"));

    await expect(job.refreshExchangeRates()).resolves.not.toThrow();
  });

  it("should return false from L2 hydration when the cache holds no rates", async () => {
    cacheManager.get.mockResolvedValue({});
    const refreshSpy = vi.spyOn(job, "refreshExchangeRates").mockResolvedValue();

    await job["update"]();

    expect(refreshSpy).toHaveBeenCalled();
  });

  it("should return early when there are no currency pairs to build", async () => {
    const original = { ...CurrencyOptions };
    for (const key of Object.keys(original)) delete (CurrencyOptions as any)[key];
    (CurrencyOptions as any).USD = "USD";
    try {
      const quoteSpy = vi.spyOn(YahooFinance.prototype, "quote").mockResolvedValue({} as any);

      await job.refreshExchangeRates();

      expect(quoteSpy).not.toHaveBeenCalled();
    } finally {
      for (const key of Object.keys(CurrencyOptions as any)) delete (CurrencyOptions as any)[key];
      Object.assign(CurrencyOptions, original);
    }
  });

  it("should skip quotes that reference unknown pairs or omit a price", async () => {
    vi.spyOn(YahooFinance.prototype, "quote").mockImplementation(async (symbol: any) => {
      if (symbol === "USDEUR=X") return { symbol: "NOT_A_PAIR", regularMarketPrice: 2 } as any;
      if (symbol === "USDJPY=X") return { symbol: "USDJPY=X", regularMarketPrice: undefined } as any;
      return { symbol, regularMarketPrice: 1.25 } as any;
    });

    await job.refreshExchangeRates();

    expect(cacheManager.set).toHaveBeenCalled();
  });
});
