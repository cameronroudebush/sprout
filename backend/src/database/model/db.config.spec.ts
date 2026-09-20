import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it } from "vitest";

setupTests();

import { DatabaseConfig, SQLiteConfig, BackupConfig, GfsBackupConfig } from "./db.config.js";

describe("DatabaseConfig", () => {
  it("should create DatabaseConfig instance with defaults", () => {
    const config = new DatabaseConfig();
    expect(config.backup).toBeInstanceOf(BackupConfig);
    expect(config.sqlite).toBeInstanceOf(SQLiteConfig);
    expect(config.backup.gfs).toBeInstanceOf(GfsBackupConfig);
    expect(config.isSqlite).toBe(true);
  });
});
