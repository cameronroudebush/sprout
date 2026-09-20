import { setupTests } from "@backend/test/helpers.js";
import { TestEntities } from "@backend/test/entities.js";
import { describe, expect, it, vi } from "vitest";

setupTests();

import { HoldingHistory } from "./holding.history.model.js";

describe("HoldingHistory", () => {
  const mockUser = TestEntities.user;
  const mockHolding = TestEntities.holding;

  it("should convert list to target currency", () => {
    const hh = HoldingHistory.fromHolding(mockHolding);
    const converted = HoldingHistory.convertListToTargetCurrency([hh], mockUser);
    expect(converted).toHaveLength(1);
  });

  it("should insert history for new holding", async () => {
    vi.spyOn(HoldingHistory.prototype, "insert").mockImplementation(function (this: HoldingHistory) {
      return Promise.resolve(this);
    });

    const hh = await HoldingHistory.insertForNewHolding(mockHolding, true);
    expect(hh.holding).toBe(mockHolding);
    expect(hh.costBasis).toBe(mockHolding.costBasis);

    const hh0 = await HoldingHistory.insertForNewHolding(mockHolding, false);
    expect(hh0.costBasis).toBe(0);
  });

  it("should create history snapshot from holding", () => {
    const now = new Date("2026-06-01T12:00:00Z");
    const hh = HoldingHistory.fromHolding(mockHolding, now);
    expect(hh.time).toEqual(now);
    expect(hh.shares).toBe(mockHolding.shares);
  });
});
