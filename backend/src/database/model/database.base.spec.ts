import { setupTests } from "@backend/test/helpers.js";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

setupTests();

import { DatabaseBase } from "./database.base.js";

class TestEntity extends DatabaseBase {
  id!: string;
  userId!: string;
  created!: Date;
}

/** Builds a fully mocked TypeORM repository used across the tests */
function createRepository() {
  return {
    metadata: { tableName: "test_entity" },
    find: vi.fn().mockResolvedValue([]),
    findOne: vi.fn().mockResolvedValue(null),
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
    createQueryBuilder: vi.fn(),
    manager: {
      connection: {
        createQueryBuilder: vi.fn(),
      },
    },
  } as any;
}

describe("DatabaseBase", () => {
  let repo: ReturnType<typeof createRepository>;

  beforeEach(() => {
    vi.restoreAllMocks();
    repo = createRepository();
    vi.spyOn(TestEntity.prototype, "getRepository").mockReturnValue(repo);
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("should resolve the repository from the shared database source", () => {
    vi.restoreAllMocks();
    const sourceRepo = { id: "shared-repo" };
    (DatabaseBase as any).database = { source: { getRepository: vi.fn().mockReturnValue(sourceRepo) } };

    const entity = new TestEntity();
    expect(entity.getRepository()).toBe(sourceRepo);
  });

  it("should provide entity helper methods and static getRepository", async () => {
    expect(TestEntity.getRepository()).toBeDefined();

    expect(await TestEntity.find({})).toEqual([]);
    repo.findOne.mockResolvedValue(new TestEntity());
    expect(await TestEntity.findOne({})).toBeInstanceOf(TestEntity);
    expect(await TestEntity.count()).toBe(0);
    expect(await TestEntity.deleteById("123")).toEqual({ affected: 1 });
    expect(await TestEntity.delete({ id: "123" } as any)).toEqual({ affected: 1 });
    expect(await TestEntity.deleteMany(["123"])).toEqual({ affected: 1 });
    expect(await TestEntity.updateWhere({}, {})).toEqual({ affected: 1 });
    expect(await TestEntity.max("id" as any)).toBe(100);
    expect(await TestEntity.min("id" as any)).toBe(10);
    expect(await TestEntity.sum("id" as any, {})).toBe(500);
    expect(await TestEntity.insertMany([new TestEntity()])).toHaveLength(1);

    const entity = new TestEntity();
    await entity.insert(false);
    entity.id = "123";

    expect(await entity.get()).toBeInstanceOf(TestEntity);

    await entity.update();
    await entity.remove();
    await entity.upsert();

    expect(repo.update).toHaveBeenCalled();
    expect(repo.remove).toHaveBeenCalled();
    expect(repo.save).toHaveBeenCalled();
  });

  it("should insert with the default wipeId enabled", async () => {
    const entity = new TestEntity();
    entity.id = "existing";

    await entity.insert();

    expect(entity.id).toBeUndefined();
    expect(repo.save).toHaveBeenCalledWith(entity);
  });

  it("should upsert many elements and skip empty input", async () => {
    expect(await TestEntity.upsertMany([])).toBeUndefined();
    expect(repo.upsert).not.toHaveBeenCalled();

    const elements = [{ id: "1" }, { id: "2" }];
    await TestEntity.upsertMany(elements as any);
    expect(repo.upsert).toHaveBeenCalledWith(elements, { conflictPaths: ["id"] });

    await TestEntity.upsertMany(elements as any, ["userId"]);
    expect(repo.upsert).toHaveBeenLastCalledWith(elements, { conflictPaths: ["userId"] });
  });

  it("should throw when get finds no matching element", async () => {
    repo.findOne.mockReturnValue(null);

    const entity = new TestEntity();
    entity.id = "missing";

    await expect(entity.get()).rejects.toThrow("Failed to locate matching element in db for id: missing");
  });

  it("should handle error cases in update and remove", async () => {
    const noIdEntity = new TestEntity();
    await expect(noIdEntity.update()).rejects.toThrow("Failed to update, no ID provided");
    await expect(noIdEntity.remove()).rejects.toThrow("Failed to update, no ID provided");
  });

  it("should execute findMostRecentInGroup with partition options, joins, and where", async () => {
    const subQueryBuilder: any = {
      select: vi.fn().mockReturnThis(),
      addSelect: vi.fn().mockReturnThis(),
      leftJoinAndSelect: vi.fn().mockReturnThis(),
      where: vi.fn().mockReturnThis(),
      getQuery: vi.fn().mockReturnValue("SELECT * FROM test_entity"),
      getParameters: vi.fn().mockReturnValue({}),
    };

    const mainQueryBuilder: any = {
      select: vi.fn().mockReturnThis(),
      from: vi.fn().mockReturnThis(),
      setParameters: vi.fn().mockReturnThis(),
      where: vi.fn().mockReturnThis(),
      getRawMany: vi.fn().mockResolvedValue([{ id: "123", row_num: 1 }]),
    };

    repo.createQueryBuilder = vi.fn().mockReturnValue(subQueryBuilder);
    repo.manager.connection.createQueryBuilder = vi.fn().mockReturnValue(mainQueryBuilder);

    const testItem = new TestEntity();
    testItem.id = "123";
    vi.spyOn(TestEntity, "find").mockResolvedValue([testItem]);

    const result = await TestEntity.findMostRecentInGroup({
      dateColumn: "created",
      partitionBy: ["userId"],
      partitionByDateOnly: false,
      where: { userId: "user-1" } as any,
      joins: ["user"],
    });

    expect(result).toEqual([testItem]);
    expect(subQueryBuilder.leftJoinAndSelect).toHaveBeenCalledWith("test_entity.user", "user");
    expect(subQueryBuilder.where).toHaveBeenCalledWith({ userId: "user-1" });
  });

  it("should execute findMostRecentInGroup with default partition options and no filters", async () => {
    const subQueryBuilder: any = {
      select: vi.fn().mockReturnThis(),
      addSelect: vi.fn().mockReturnThis(),
      leftJoinAndSelect: vi.fn().mockReturnThis(),
      where: vi.fn().mockReturnThis(),
      getQuery: vi.fn().mockReturnValue("SELECT * FROM test_entity"),
      getParameters: vi.fn().mockReturnValue({}),
    };

    const mainQueryBuilder: any = {
      select: vi.fn().mockReturnThis(),
      from: vi.fn().mockReturnThis(),
      setParameters: vi.fn().mockReturnThis(),
      where: vi.fn().mockReturnThis(),
      getRawMany: vi.fn().mockResolvedValue([]),
    };

    repo.createQueryBuilder = vi.fn().mockReturnValue(subQueryBuilder);
    repo.manager.connection.createQueryBuilder = vi.fn().mockReturnValue(mainQueryBuilder);

    const result = await TestEntity.findMostRecentInGroup({
      dateColumn: "created",
      partitionBy: ["userId"],
    });

    expect(result).toEqual([]);
    expect(subQueryBuilder.leftJoinAndSelect).not.toHaveBeenCalled();
    expect(subQueryBuilder.where).not.toHaveBeenCalled();
    expect(subQueryBuilder.addSelect).toHaveBeenCalledWith(expect.stringContaining('DATE("test_entity"."created")'));
  });
});
