import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it } from "vitest";

setupTests();

vi.mock("glob", () => ({
  glob: {
    sync: vi.fn().mockReturnValue(["path"]),
  },
}));

import { DatabaseConfig, SQLiteConfig, BackupConfig, GfsBackupConfig } from "./db.config.js";

describe("DatabaseConfig", () => {
  it("should create DatabaseConfig instance with defaults and load migrations", () => {
    const config = new DatabaseConfig();
    expect(config.backup).toBeInstanceOf(BackupConfig);
    expect(config.sqlite).toBeInstanceOf(SQLiteConfig);
    expect(config.backup.gfs).toBeInstanceOf(GfsBackupConfig);
    expect(config.isSqlite).toBe(true);

    const dbConfig = config.dbConfig;
    expect(dbConfig.type).toBe("better-sqlite3");
  });

  it("should fall back to sqlite behavior for a non-standard database type", () => {
    const config = new DatabaseConfig();
    (config as unknown as { type: string }).type = "postgres";

    expect(config.isSqlite).toBe(false);

    const dbConfig = config.dbConfig;
    expect(dbConfig.type).toBe("postgres");
    expect(Array.isArray(dbConfig.migrations)).toBe(true);
  });
});
