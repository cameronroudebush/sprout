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
        createSchemaBuilder: () => ({
          log: vi.fn().mockResolvedValue({ upQueries: [] }),
        }),
      };
    },
  };
});

setupTests();

import { DatabaseService } from "./database.service.js";

describe("DatabaseService", () => {
  it("should initialize database connection and check migrations", async () => {
    const service = new DatabaseService();
    vi.spyOn(service, "databaseExists").mockResolvedValue(true);
    vi.spyOn(service, "executeMigrations").mockResolvedValue([]);

    await service.init();
    expect(service.source.initialize).toHaveBeenCalled();
  });
});
