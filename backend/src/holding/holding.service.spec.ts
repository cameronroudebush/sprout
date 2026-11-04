import { TestEntities } from "@backend/test/entities.js";
import { setupTests } from "@backend/test/helpers.js";
import { beforeEach, describe, expect, it, vi } from "vitest";

setupTests();

import { MarketQuoteType } from "@backend/holding/model/api/mark.index.dto.js";
import { Holding } from "@backend/holding/model/holding.model.js";
import { HttpException } from "@nestjs/common";
import { HoldingService } from "./holding.service.js";

describe("HoldingService", () => {
  let service: HoldingService;
  let netWorthService: any;
  let cacheManager: any;

  const mockAccount = TestEntities.account;
  const mockHolding = TestEntities.holding;

  beforeEach(() => {
    vi.restoreAllMocks();
    netWorthService = {
      getHistoryForHoldings: vi.fn().mockResolvedValue([{ history: { connectedId: "h1" } }]),
      getHistoryForHolding: vi.fn().mockResolvedValue({ history: {}, timeline: () => [] }),
    };
    cacheManager = {
      get: vi.fn().mockResolvedValue(null),
      set: vi.fn().mockResolvedValue(undefined),
    };

    service = new HoldingService(netWorthService, cacheManager);
  });

  describe("getHistoryForAccount", () => {
    it("should return entity histories for account holdings", async () => {
      const result = await service.getHistoryForAccount(mockAccount);
      expect(result).toHaveLength(1);
    });
  });

  describe("getTimelineForHolding", () => {
    it("should return history with timeline for individual holding", async () => {
      const result = await service.getTimelineForHolding(mockHolding);
      expect(result.history).toBeDefined();
    });
  });

  describe("getLiveHoldingPrices", () => {
    it("should fetch prices from cache when available", async () => {
      cacheManager.get.mockResolvedValue({ symbol: "AAPL", regularMarketPrice: 150 });
      const results = await service.getLiveHoldingPrices(["AAPL"]);
      expect(results).toHaveLength(1);
    });

    it("should handle quoteSummary rejection gracefully for missing symbols", async () => {
      cacheManager.get.mockResolvedValue(null);
      vi.spyOn((service as any).yf, "quoteSummary").mockRejectedValue(new Error("Symbol not found"));

      const results = await service.getLiveHoldingPrices(["UNKNOWN_SYM"]);
      expect(results).toHaveLength(1);
      expect(results[0]!.symbol).toBe("UNKNOWN_SYM");
      expect(results[0]!.type).toBe(MarketQuoteType.INVALID);
    });

    it("should fetch missing prices from yahoo finance and handle mutual fund dividends", async () => {
      cacheManager.get.mockResolvedValue(null);
      vi.spyOn((service as any).yf, "quoteSummary").mockResolvedValue({
        price: { symbol: "VFIAX", regularMarketPrice: 400, quoteType: "MUTUALFUND" },
        summaryDetail: { dividendYield: 0.01 },
      });

      vi.spyOn((service as any).yf, "chart").mockResolvedValue({
        events: {
          dividends: [{ amount: 10 }],
        },
      } as any);

      const results = await service.getLiveHoldingPrices(["VFIAX"]);
      expect(results).toHaveLength(1);
      expect(cacheManager.set).toHaveBeenCalled();
    });

    it("should handle error in chart fetch inside mutual fund dividends gracefully", async () => {
      cacheManager.get.mockResolvedValue(null);
      vi.spyOn((service as any).yf, "quoteSummary").mockResolvedValue({
        price: { symbol: "VFIAX", regularMarketPrice: 400, quoteType: "MUTUALFUND" },
        summaryDetail: { dividendYield: 0.01 },
      });

      vi.spyOn((service as any).yf, "chart").mockRejectedValue(new Error("Chart error"));

      const results = await service.getLiveHoldingPrices(["VFIAX"]);
      expect(results).toHaveLength(1);
    });

    it("should handle dividend events with missing amounts and a lower calculated yield", async () => {
      cacheManager.get.mockResolvedValue(null);
      vi.spyOn((service as any).yf, "quoteSummary").mockResolvedValue({
        price: { symbol: "MUTF", regularMarketPrice: 400, quoteType: "MUTUALFUND" },
        summaryDetail: { dividendYield: 0.5 },
      });
      vi.spyOn((service as any).yf, "chart").mockResolvedValue({ events: { dividends: [{}, { amount: undefined }] } } as any);

      const results = await service.getLiveHoldingPrices(["MUTF"]);
      expect(results).toHaveLength(1);
    });

    it("should skip dividend yield calculation when the market price is not positive", async () => {
      cacheManager.get.mockResolvedValue(null);
      vi.spyOn((service as any).yf, "quoteSummary").mockResolvedValue({
        price: { symbol: "ZEROFUND", regularMarketPrice: 0, quoteType: "MUTUALFUND" },
        summaryDetail: { dividendYield: 0.01 },
      });
      vi.spyOn((service as any).yf, "chart").mockResolvedValue({ events: { dividends: [{ amount: 10 }] } } as any);

      const results = await service.getLiveHoldingPrices(["ZEROFUND"]);
      expect(results).toHaveLength(1);
    });

    it("should fall back to the requested symbol when the quote payload omits it", async () => {
      cacheManager.get.mockResolvedValue(null);
      vi.spyOn((service as any).yf, "quoteSummary").mockResolvedValue({
        price: { regularMarketPrice: 150 },
      } as any);

      const results = await service.getLiveHoldingPrices(["NO_SYMBOL"]);

      expect(results).toHaveLength(1);
      expect(results[0]!.symbol).toBe("NO_SYMBOL");
    });

    it("should throw HttpException when cacheManager set fails", async () => {
      cacheManager.get.mockResolvedValue(null);
      vi.spyOn((service as any).yf, "quoteSummary").mockResolvedValue({
        price: { symbol: "AAPL", regularMarketPrice: 150 },
      });
      cacheManager.set.mockRejectedValue(new Error("Cache set error"));

      await expect(service.getLiveHoldingPrices(["AAPL"])).rejects.toThrow(HttpException);
    });
  });

  describe("getMajorIndices", () => {
    it("should map major index names properly and fallback to symbol if unknown index", async () => {
      cacheManager.get.mockResolvedValue(null);
      vi.spyOn((service as any).yf, "quoteSummary").mockImplementation((symbol: string) =>
        Promise.resolve({
          price: { symbol: symbol === "^GSPC" ? "UNKNOWN_INDEX" : symbol, regularMarketPrice: 4000, quoteType: "INDEX" },
          summaryDetail: {},
        }),
      );

      const indices = await service.getMajorIndices();
      expect(indices.length).toBeGreaterThan(0);
      expect(indices.some((idx) => idx.name === "UNKNOWN_INDEX")).toBe(true);
    });
  });

  describe("getPortfolioSummary", () => {
    it("should total live holdings and daily movement", async () => {
      vi.spyOn(Holding, "find").mockResolvedValue([mockHolding]);
      vi.spyOn(service, "getLiveHoldingPrices").mockResolvedValue([
        { symbol: "AAPL", price: 200, change: 2, currency: "USD", type: MarketQuoteType.EQUITY } as any,
      ]);

      const result = await service.getPortfolioSummary(TestEntities.user);

      expect(Holding.find).toHaveBeenCalledWith({ where: { account: { user: { id: TestEntities.user.id } }, shares: expect.anything() } });
      expect(service.getLiveHoldingPrices).toHaveBeenCalledWith(["AAPL"]);
      expect(result).toEqual({
        totalValue: 2000,
        dayChange: 20,
        dayChangePercent: expect.closeTo(1.0101, 3),
      });
    });

    it("should fall back to stored values and close price when live quote is invalid", async () => {
      const holding = { ...mockHolding, marketValue: 1800, shares: 10, currency: "USD", extra: { closePrice: 175 } } as Holding;
      vi.spyOn(Holding, "find").mockResolvedValue([holding]);
      vi.spyOn(service, "getLiveHoldingPrices").mockResolvedValue([{ symbol: "AAPL", price: 0, type: MarketQuoteType.INVALID } as any]);

      const result = await service.getPortfolioSummary(TestEntities.user);

      expect(result).toEqual({
        totalValue: 1800,
        dayChange: 50,
        dayChangePercent: expect.closeTo(2.8571, 3),
      });
    });

    it("should use stored value without daily change when quote and close price are missing", async () => {
      const holding = { ...mockHolding, marketValue: 500, shares: 10, currency: "USD", extra: {} } as Holding;
      vi.spyOn(Holding, "find").mockResolvedValue([holding]);
      vi.spyOn(service, "getLiveHoldingPrices").mockResolvedValue([]);

      const result = await service.getPortfolioSummary(TestEntities.user);

      expect(result).toEqual({
        totalValue: 500,
        dayChange: 0,
        dayChangePercent: 0,
      });
    });

    it("should fall back to USD, holding currency, and zero quote change when values are missing", async () => {
      const holding = { ...mockHolding, marketValue: 500, shares: 10, currency: "USD" } as Holding;
      vi.spyOn(Holding, "find").mockResolvedValue([holding]);
      vi.spyOn(service, "getLiveHoldingPrices").mockResolvedValue([{ symbol: "AAPL", price: 20, type: MarketQuoteType.EQUITY } as any]);

      const result = await service.getPortfolioSummary({ ...TestEntities.user, config: undefined } as any);

      expect(result).toEqual({
        totalValue: 200,
        dayChange: 0,
        dayChangePercent: 0,
      });
    });

    it("should return zero percentage when daily change makes previous value zero", async () => {
      const holding = { ...mockHolding, marketValue: 500, shares: 10, currency: "USD" } as Holding;
      vi.spyOn(Holding, "find").mockResolvedValue([holding]);
      vi.spyOn(service, "getLiveHoldingPrices").mockResolvedValue([
        { symbol: "AAPL", price: 20, change: 20, currency: "USD", type: MarketQuoteType.EQUITY } as any,
      ]);

      const result = await service.getPortfolioSummary(TestEntities.user);

      expect(result).toEqual({
        totalValue: 200,
        dayChange: 200,
        dayChangePercent: 0,
      });
    });

    it("should guard against a non-finite daily change percentage", async () => {
      vi.spyOn(Holding, "find").mockResolvedValue([mockHolding]);
      vi.spyOn(service, "getLiveHoldingPrices").mockResolvedValue([
        { symbol: "AAPL", price: Infinity, change: Infinity, currency: "USD", type: MarketQuoteType.EQUITY } as any,
      ]);

      const result = await service.getPortfolioSummary(TestEntities.user);

      expect(result.dayChangePercent).toBe(0);
    });

    it("should return zero summary for users without holdings", async () => {
      vi.spyOn(Holding, "find").mockResolvedValue([]);
      vi.spyOn(service, "getLiveHoldingPrices").mockResolvedValue([]);

      const result = await service.getPortfolioSummary(TestEntities.user);

      expect(result).toEqual({
        totalValue: 0,
        dayChange: 0,
        dayChangePercent: 0,
      });
    });
  });

  describe("getMajorIndicesTimeline", () => {
    it("should return cached timeline if present", async () => {
      cacheManager.get.mockResolvedValue([{ symbol: "^GSPC" }]);
      const res = await service.getMajorIndicesTimeline();
      expect(res).toHaveLength(1);
    });

    it("should fetch and cache timeline if not in cache", async () => {
      cacheManager.get.mockResolvedValue(null);
      vi.spyOn((service as any).yf, "chart").mockResolvedValue({
        quotes: [
          { date: "2026-06-01", close: 100 },
          { date: "2026-06-02", close: 105 },
        ],
      } as any);

      const res = await service.getMajorIndicesTimeline();
      expect(res.length).toBeGreaterThan(0);
    });

    it("should handle null quotes in chart response during timeline mapping", async () => {
      cacheManager.get.mockResolvedValue(null);
      vi.spyOn((service as any).yf, "chart").mockResolvedValue({
        quotes: [null, { date: "2026-06-01", close: 100 }],
      } as any);

      const res = await service.getMajorIndicesTimeline();
      expect(res.length).toBeGreaterThan(0);
    });

    it("should handle a rejected chart lookup for one index while mapping the rest", async () => {
      cacheManager.get.mockResolvedValue(null);
      vi.spyOn((service as any).yf, "chart").mockImplementation((symbol: string) =>
        symbol === "^GSPC" ? Promise.reject(new Error("Index unavailable")) : Promise.resolve({ quotes: [{ date: "2026-06-01", close: 100 }] } as any),
      );

      const res = await service.getMajorIndicesTimeline();
      expect(res).toHaveLength(3);
      expect(res[0]!.timeline).toHaveLength(0);
    });

    it("should return an empty timeline when all quotes are invalid", async () => {
      cacheManager.get.mockResolvedValue(null);
      vi.spyOn((service as any).yf, "chart").mockResolvedValue({
        quotes: [{ date: null, close: null }],
      } as any);

      const res = await service.getMajorIndicesTimeline();
      expect(res).toHaveLength(3);
      expect(res[0]!.timeline).toHaveLength(0);
    });

    it("should handle error in chart fetch and throw SERVICE_UNAVAILABLE if overall timeline fails", async () => {
      cacheManager.get.mockResolvedValue(null);
      cacheManager.set.mockRejectedValue(new Error("Cache set error"));

      await expect(service.getMajorIndicesTimeline()).rejects.toThrow(HttpException);
    });
  });
});
