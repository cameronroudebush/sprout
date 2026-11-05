import { setupTests } from "@backend/test/helpers";
setupTests();

import { MarketIndexDto } from "@backend/holding/model/api/mark.index.dto";

describe("MarketIndexDto", () => {
  it("should construct from raw price/summary data", () => {
    const raw = {
      symbol: "^GSPC",
      shortName: "S&P 500",
      regularMarketPrice: 5000,
      regularMarketChange: 25,
      regularMarketChangePercent: 0.5,
      dividendYield: 1.5,
    };

    const dto = new MarketIndexDto(raw);

    expect(dto.symbol).toBe("^GSPC");
    expect(dto.price).toBe(5000);
    expect(dto.change).toBe(25);
    expect(dto.hasMarketTimestamp).toBe(false);
  });

  it("should identify when a source market timestamp is available", () => {
    const dto = new MarketIndexDto({ symbol: "^GSPC", regularMarketTime: "2026-11-05T21:00:00.000Z" });

    expect(dto.hasMarketTimestamp).toBe(true);
    expect(dto.lastUpdated).toBe("2026-11-05T21:00:00.000Z");
  });
});
