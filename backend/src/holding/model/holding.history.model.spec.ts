import { setupTests } from "@backend/test/helpers";
setupTests();

import { HoldingHistory } from "@backend/holding/model/holding.history.model";
import { TestEntities } from "@backend/test/entities";

describe("HoldingHistory Model", () => {
  const holding = TestEntities.holding;

  it("should create holding history instance", () => {
    const history = HoldingHistory.fromPlain({
      holding,
      marketValue: 1200,
      costBasis: 1000,
      time: new Date(),
    });

    expect(history.holding).toEqual(holding);
    expect(history.marketValue).toBe(1200);
  });
});
