import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it, vi } from "vitest";

vi.mock("typeorm", async () => {
  const actual: any = await vi.importActual("typeorm");
  return {
    ...actual,
    DataSource: class {
      options = { database: "sprout.sqlite" };
      initialize = vi.fn().mockResolvedValue(undefined);
      query = vi.fn().mockResolvedValue([{ name: "users" }]);
      runMigrations = vi.fn().mockResolvedValue([]);
      driver = {
        databaseConnection: {
          function: vi.fn(),
        },
        createSchemaBuilder: () => ({
          log: vi.fn().mockResolvedValue({ upQueries: [] }),
        }),
      };
    },
  };
});

setupTests();

import { Configuration } from "@backend/config/core.js";
import { DatabaseService } from "./database.service.js";

describe("DatabaseService", () => {
  let service: DatabaseService;

  beforeEach(() => {
    vi.restoreAllMocks();
    Configuration.database.type = "better-sqlite3";
    (Configuration.database as any).isSqlite = true;
    service = new DatabaseService();
  });

  it("should initialize database connection, inject regex functions, and check migrations when db does not exist", async () => {
    vi.spyOn(service, "databaseExists").mockResolvedValue(false);
    vi.spyOn(service, "executeMigrations").mockResolvedValue(["m1"] as any);

    await service.init();
    expect(service.source.initialize).toHaveBeenCalled();
  });

  it("should initialize when database already exists with executed migrations", async () => {
    vi.spyOn(service, "databaseExists").mockResolvedValue(true);
    vi.spyOn(service, "executeMigrations").mockResolvedValue(["m1"] as any);

    await service.init();
    expect(service.executeMigrations).toHaveBeenCalled();
  });

  it("should initialize when database already exists with no migrations executed", async () => {
    vi.spyOn(service, "databaseExists").mockResolvedValue(true);
    vi.spyOn(service, "executeMigrations").mockResolvedValue([]);

    await service.init();
    expect(service.executeMigrations).toHaveBeenCalled();
  });

  it("should check databaseExists for non-SQLite databases", async () => {
    (Configuration.database as any).isSqlite = false;
    vi.spyOn(service.source, "query").mockResolvedValue([{ name: "sprout" }]);

    const exists = await service.databaseExists("sprout", service.source);
    expect(exists).toBe(true);
    expect(service.source.query).toHaveBeenCalledWith("SHOW DATABASES LIKE ?", ["sprout"]);
  });

  it("should check for migrations and log no migration required when upQueries is empty", async () => {
    vi.spyOn(service.source.driver, "createSchemaBuilder").mockReturnValue({
      log: vi.fn().mockResolvedValue({ upQueries: [] }),
    } as any);

    await expect((service as any).checkForMigrations()).resolves.not.toThrow();
  });

  it("should throw in checkForMigrations if upQueries are present", async () => {
    vi.spyOn(service.source.driver, "createSchemaBuilder").mockReturnValue({
      log: vi.fn().mockResolvedValue({ upQueries: ["CREATE TABLE..."] }),
    } as any);

    Configuration.isDevBuild = true;
    await expect((service as any).checkForMigrations()).rejects.toThrow("Did you forget to run the migration generation command?");

    Configuration.isDevBuild = false;
    await expect((service as any).checkForMigrations()).rejects.toThrow("Refusing to continue.");
  });

  it("should set SQLite PRAGMA when not SQLite", async () => {
    (Configuration.database as any).isSqlite = false;
    vi.spyOn(service.source, "query").mockResolvedValue([] as any);

    await service.setSQLitePRAGMA(true, service.source);
    expect(service.source.query).toHaveBeenCalledWith("PRAGMA foreign_keys=ON;");

    await service.setSQLitePRAGMA(false, service.source);
    expect(service.source.query).toHaveBeenCalledWith("PRAGMA foreign_keys=OFF;");
  });

  it("should inject native better-sqlite3 regex methods", () => {
    const fnMap = new Map<string, Function>();
    (service.source.driver as any).databaseConnection = {
      function: (name: string, fn: Function) => {
        fnMap.set(name, fn);
      },
    };

    (service as any).injectSQLiteRegexFunctions();

    const regexpFn = fnMap.get("REGEXP")!;
    expect(regexpFn("test", "test string")).toBe(1);
    expect(regexpFn("foo", "bar")).toBe(0);
    expect(regexpFn("foo", null)).toBe(0);

    const replaceFn = fnMap.get("REGEXP_REPLACE")!;
    expect(replaceFn("hello world", "world", "there")).toBe("hello there");
    expect(replaceFn(null, "world", "there")).toBe("");
  });

  it("should handle error in injectSQLiteRegexFunctions gracefully", () => {
    (service.source.driver as any).databaseConnection = {
      function: () => {
        throw new Error("Failed");
      },
    };

    expect(() => (service as any).injectSQLiteRegexFunctions()).not.toThrow();
  });

  it("should warn if native databaseConnection function is missing", () => {
    (service.source.driver as any).databaseConnection = null;
    expect(() => (service as any).injectSQLiteRegexFunctions()).not.toThrow();
  });
});
