import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it, vi } from "vitest";

setupTests();

import { Utility } from "./utility.js";

describe("Utility", () => {
  it("should select random element, shuffle array, and delay execution", async () => {
    const arr = [1, 2, 3, 4, 5];
    const picked = Utility.randomFromArray(arr);
    expect(arr).toContain(picked);

    const shuffled = Utility.shuffleArray([...arr]);
    expect(shuffled).toHaveLength(5);

    const start = Date.now();
    await Utility.delay(10);
    expect(Date.now() - start).toBeGreaterThanOrEqual(5);
  });
});
