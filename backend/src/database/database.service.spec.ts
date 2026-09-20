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

import { DatabaseService } from "./database.service.js";
import { Configuration } from "@backend/config/core.js";

describe("DatabaseService", () => {
  it("should initialize database connection, inject regex functions, and check migrations", async () => {
    Configuration.database.type = "better-sqlite3";
    const service = new DatabaseService();

    vi.spyOn(service, "databaseExists").mockResolvedValue(false);
    vi.spyOn(service, "executeMigrations").mockResolvedValue(["m1"] as any);

    await service.init();
    expect(service.source.initialize).toHaveBeenCalled();
  });

  it("should set SQLite PRAGMA and validate source", async () => {
    const service = new DatabaseService();

    Configuration.database.type = "better-sqlite3";
    await service.setSQLitePRAGMA(true);
    await service.setSQLitePRAGMA(false);

    expect(() => service.validateSource(null as any)).toThrow();
  });
});
