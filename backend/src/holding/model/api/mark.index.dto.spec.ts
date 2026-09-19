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
  });
});
