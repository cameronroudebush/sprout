import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { Configuration } from "@backend/config/core.js";
import { DatabaseBackupJob } from "@backend/core/jobs/backup.js";
import fs from "fs";

describe("DatabaseBackupJob", () => {
  let runner: DatabaseBackupJob;

  beforeEach(() => {
    vi.restoreAllMocks();
    runner = new DatabaseBackupJob();
  });

  describe("update", () => {
    it("should create directory if missing and copy db file", async () => {
      vi.spyOn(fs, "existsSync").mockReturnValue(false);
      vi.spyOn(fs, "mkdirSync").mockReturnValue(undefined as any);
      vi.spyOn(fs, "copyFileSync").mockReturnValue(undefined as any);
      vi.spyOn(fs, "readdirSync").mockReturnValue([]);

      Configuration.database.backup.directory = "/mock/backups";
      (Configuration.database as any).dbConfig = { database: "/mock/sprout.sqlite" };

      await (runner as any).update();

      expect(fs.mkdirSync).toHaveBeenCalledWith("/mock/backups", { recursive: true });
      expect(fs.copyFileSync).toHaveBeenCalledWith("/mock/sprout.sqlite", expect.stringContaining("sprout_backup_"));
    });

    it("should skip directory creation when the backup directory already exists", async () => {
      vi.spyOn(fs, "existsSync").mockReturnValue(true);
      const mkdirSpy = vi.spyOn(fs, "mkdirSync").mockReturnValue(undefined as any);
      vi.spyOn(fs, "copyFileSync").mockReturnValue(undefined as any);
      vi.spyOn(fs, "readdirSync").mockReturnValue([]);

      Configuration.database.backup.directory = "/mock/backups";
      (Configuration.database as any).dbConfig = { database: "/mock/sprout.sqlite" };

      await (runner as any).update();

      expect(mkdirSpy).not.toHaveBeenCalled();
      expect(fs.copyFileSync).toHaveBeenCalled();
    });
  });

  describe("parseDateFromFileName", () => {
    it("should parse valid backup file names and return null for invalid ones", () => {
      const valid = (runner as any).parseDateFromFileName("sprout_backup_2026-05-15_12-30-00.sqlite");
      expect(valid).toBeInstanceOf(Date);
      expect(valid?.getFullYear()).toBe(2026);

      const invalid = (runner as any).parseDateFromFileName("other_file.txt");
      expect(invalid).toBeNull();
    });
  });

  describe("evaluateBackups and pruning", () => {
    it("should evaluate backup tiers and prune unneeded files", () => {
      Configuration.database.backup.directory = "/mock/backups";
      Configuration.database.backup.gfs = {
        dailyCount: 1,
        weeklyCount: 1,
        monthlyCount: 1,
        quarterlyCount: 1,
        yearlyCount: 1,
      };

      vi.spyOn(fs, "existsSync").mockReturnValue(true);
      vi.spyOn(fs, "readdirSync").mockReturnValue([
        "sprout_backup_2026-05-15_12-00-00.sqlite",
        "sprout_backup_2026-05-14_12-00-00.sqlite", // Excess daily
        "invalid_file.txt",
      ] as any);
      vi.spyOn(fs, "statSync").mockReturnValue({ size: 1024 } as any);
      const unlinkSpy = vi.spyOn(fs, "unlinkSync").mockReturnValue(undefined as any);

      const summary = runner.getBackupSummary();
      expect(summary.totalCount).toBe(2);
      expect(summary.totalSizeBytes).toBe(2048);

      (runner as any).pruneGfsBackups();
      expect(unlinkSpy).toHaveBeenCalled();
    });

    it("should skip unparseable backup files and handle years beginning on a non-Thursday", () => {
      Configuration.database.backup.directory = "/mock/backups";
      Configuration.database.backup.gfs = {
        dailyCount: 1,
        weeklyCount: 1,
        monthlyCount: 1,
        quarterlyCount: 1,
        yearlyCount: 1,
      };

      vi.spyOn(fs, "existsSync").mockReturnValue(true);
      vi.spyOn(fs, "readdirSync").mockReturnValue(["sprout_backup_bad.sqlite", "sprout_backup_2025-05-15_12-00-00.sqlite"] as any);
      vi.spyOn(fs, "statSync").mockReturnValue({ size: 512 } as any);

      const summary = runner.getBackupSummary();

      expect(summary.totalCount).toBe(1);
      expect(summary.backups[0]!.tiers).toContain("weekly");
    });

    it("should fall back to default GFS retention counts when none are configured", () => {
      const originalGfs = Configuration.database.backup.gfs;
      (Configuration.database.backup as any).gfs = undefined;
      try {
        vi.spyOn(fs, "existsSync").mockReturnValue(true);
        vi.spyOn(fs, "readdirSync").mockReturnValue([] as any);

        const summary = runner.getBackupSummary();

        expect(summary.totalCount).toBe(0);
      } finally {
        Configuration.database.backup.gfs = originalGfs;
      }
    });
  });
});
