import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { CurrencyHelper } from "@backend/core/model/utility/currency.helper.js";
import { Holding } from "@backend/holding/model/holding.model.js";
import { TestEntities } from "@backend/test/entities.js";

describe("Holding Model", () => {
  const account = TestEntities.account;
  const user = TestEntities.user;

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("should create holding instance with constructor and fromPlain", () => {
    const holding = new Holding("USD", 1000, "Apple Inc.", 1500, 100, 10, "AAPL", account);
    expect(holding.symbol).toBe("AAPL");
    expect(holding.currency).toBe("USD");
    expect(holding.costBasis).toBe(1000);
    expect(holding.description).toBe("Apple Inc.");
    expect(holding.marketValue).toBe(1500);
    expect(holding.purchasePrice).toBe(100);
    expect(holding.shares).toBe(10);
    expect(holding.account).toBe(account);
  });

  it("should get holdings for account", async () => {
    vi.spyOn(Holding, "find").mockResolvedValue([]);
    const res = await Holding.getForAccount(account);
    expect(res).toEqual([]);
    expect(Holding.find).toHaveBeenCalledWith({
      where: { account: { id: account.id }, shares: expect.anything() },
    });
  });

  it("should convert list to target currency", () => {
    const spy = vi.spyOn(CurrencyHelper, "convertList").mockImplementation(() => []);
    const holding = new Holding("USD", 1000, "Apple", 1500, 100, 10, "AAPL", account);
    const result = Holding.convertListToTargetCurrency([holding], user);
    expect(spy).toHaveBeenCalledWith([holding], ["costBasis", "marketValue", "purchasePrice"], "currency", user);
    expect(result).toEqual([holding]);
  });
});
