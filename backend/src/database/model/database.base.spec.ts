import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it, vi } from "vitest";

setupTests();

import { DatabaseBase } from "./database.base.js";

class TestEntity extends DatabaseBase {
  id!: string;
}

describe("DatabaseBase", () => {
  it("should provide entity helper methods", async () => {
    const repo: any = {
      find: vi.fn().mockResolvedValue([]),
      findOne: vi.fn().mockImplementation(({ where }) => {
        if (where && where.id === "123") return Promise.resolve(new TestEntity());
        return Promise.resolve(null);
      }),
      count: vi.fn().mockResolvedValue(0),
      save: vi.fn().mockImplementation((val) => {
        if (Array.isArray(val)) return Promise.resolve(val);
        const e = new TestEntity();
        e.id = "123";
        return Promise.resolve(e);
      }),
      remove: vi.fn().mockResolvedValue(undefined),
      delete: vi.fn().mockResolvedValue({ affected: 1 }),
      update: vi.fn().mockResolvedValue({ affected: 1 }),
      upsert: vi.fn().mockResolvedValue({ identifiers: [] }),
      maximum: vi.fn().mockResolvedValue(100),
      minimum: vi.fn().mockResolvedValue(10),
      sum: vi.fn().mockResolvedValue(500),
    };

    vi.spyOn(TestEntity.prototype, "getRepository").mockReturnValue(repo);

    expect(await TestEntity.find({})).toEqual([]);
    expect(await TestEntity.findOne({})).toBeNull();
    expect(await TestEntity.count()).toBe(0);
    expect(await TestEntity.deleteById("123")).toEqual({ affected: 1 });
    expect(await TestEntity.delete({ id: "123" } as any)).toEqual({ affected: 1 });
    expect(await TestEntity.deleteMany(["123"])).toEqual({ affected: 1 });
    expect(await TestEntity.updateWhere({}, {})).toEqual({ affected: 1 });
    expect(await TestEntity.max("id" as any)).toBe(100);
    expect(await TestEntity.min("id" as any)).toBe(10);
    expect(await TestEntity.sum("id" as any, {})).toBe(500);
    expect(await TestEntity.insertMany([new TestEntity()])).toHaveLength(1);
    expect(await TestEntity.upsertMany([])).toBeUndefined();

    const entity = new TestEntity();
    await entity.insert(false);
    entity.id = "123";

    expect(await entity.get()).toBeDefined();

    await entity.update();
    await entity.remove();
    await entity.upsert();
  });

  it("should handle error cases in update and remove", async () => {
    const noIdEntity = new TestEntity();
    await expect(noIdEntity.update()).rejects.toThrow();
    await expect(noIdEntity.remove()).rejects.toThrow();
  });
});
