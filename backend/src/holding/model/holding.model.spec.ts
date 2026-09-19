import { setupTests } from "@backend/test/helpers";
setupTests();

import { Holding } from "@backend/holding/model/holding.model";
import { TestEntities } from "@backend/test/entities";

describe("Holding Model", () => {
  const account = TestEntities.account;

  it("should create holding instance with valid parameters", () => {
    const holding = Holding.fromPlain({
      account,
      symbol: "AAPL",
      description: "Apple Inc.",
      marketValue: 1500,
      costBasis: 1000,
      shares: 10,
      purchasePrice: 100,
      currency: "USD",
    });

    expect(holding.symbol).toBe("AAPL");
    expect(holding.account).toEqual(account);
  });
});
