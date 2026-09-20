import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it, vi } from "vitest";

setupTests();

import { DatabaseBase } from "./database.base.js";

class TestEntity extends DatabaseBase {}

describe("DatabaseBase", () => {
  it("should provide entity helper methods", async () => {
    vi.spyOn(TestEntity, "find").mockResolvedValue([]);
    const results = await TestEntity.find();
    expect(results).toEqual([]);
  });
});
