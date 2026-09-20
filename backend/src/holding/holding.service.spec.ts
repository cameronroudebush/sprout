import { setupTests } from "@backend/test/helpers.js";
import { TestEntities } from "@backend/test/entities.js";
import { describe, expect, it, vi, beforeEach } from "vitest";

setupTests();

import { HoldingService } from "./holding.service.js";

describe("HoldingService", () => {
  let service: HoldingService;
  let netWorthService: any;
  let cacheManager: any;

  const mockAccount = TestEntities.account;
  const mockHolding = TestEntities.holding;

  beforeEach(() => {
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

    it("should fetch missing prices from yahoo finance", async () => {
      cacheManager.get.mockResolvedValue(null);
      vi.spyOn((service as any).yf, "quoteSummary").mockResolvedValue({
        price: { symbol: "AAPL", regularMarketPrice: 150, quoteType: "EQUITY" },
        summaryDetail: { dividendYield: 0.01 },
      });

      const results = await service.getLiveHoldingPrices(["AAPL"]);
      expect(results).toHaveLength(1);
    });
  });

  describe("getMajorIndices", () => {
    it("should map major index names properly", async () => {
      cacheManager.get.mockResolvedValue(null);
      vi.spyOn((service as any).yf, "quoteSummary").mockImplementation((symbol: string) =>
        Promise.resolve({
          price: { symbol, regularMarketPrice: 4000, quoteType: "INDEX" },
          summaryDetail: {},
        }),
      );

      const indices = await service.getMajorIndices();
      expect(indices.length).toBeGreaterThan(0);
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
  });
});
