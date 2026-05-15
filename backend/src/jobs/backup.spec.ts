import { Configuration } from "@backend/config/core";
import { DatabaseBackupJob } from "@backend/jobs/backup";
import { Test, TestingModule } from "@nestjs/testing";
import * as fs from "fs";

// Mock the built-in fs module, but keep original implementations for other non-mocked items so we don't break fast-glob / node internals
jest.mock("fs", () => {
  const actual = jest.requireActual("fs");
  return {
    ...actual,
    existsSync: jest.fn(),
    mkdirSync: jest.fn(),
    copyFileSync: jest.fn(),
    readdirSync: jest.fn(),
    unlinkSync: jest.fn(),
  };
});

describe("DatabaseBackupJob", () => {
  let job: DatabaseBackupJob;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [DatabaseBackupJob],
    }).compile();

    job = module.get<DatabaseBackupJob>(DatabaseBackupJob);

    // Set some reliable base config values for the test
    Configuration.database.backup.enabled = true;
    Configuration.database.backup.count = 3;
    Configuration.database.backup.directory = "/mock/backup/dir";

    // Spy on the dbConfig getter to return a mock database path
    jest.spyOn(Configuration.database, "dbConfig", "get").mockReturnValue({ database: "/mock/db/sprout.sqlite" } as any);

    jest.clearAllMocks();
  });

  describe("Constructor", () => {
    it("should instantiate with correct jobName", () => {
      expect(job.jobName).toBe("db:backup");
    });
  });

  describe("start", () => {
    it("should return immediately if backups are disabled", async () => {
      Configuration.database.backup.enabled = false;
      const result = await job.start();
      expect(result).toBe(job);
    });

    it("should call super.start(true) when enabled", async () => {
      Configuration.database.backup.enabled = true;
      // We mock super.start by spying on BackgroundJob's start method
      const superStartSpy = jest.spyOn(Object.getPrototypeOf(DatabaseBackupJob.prototype), "start").mockResolvedValue(job);
      const result = await job.start();

      expect(superStartSpy).toHaveBeenCalledWith(true);
      expect(result).toBe(job);
      superStartSpy.mockRestore();
    });
  });

  describe("update", () => {
    it("should create directory if it does not exist, copy file, and clean old backups", async () => {
      // Mock directory doesn't exist
      (fs.existsSync as jest.Mock).mockReturnValue(false);

      // Mock that there are 5 backup files in the directory (limit is 3)
      (fs.readdirSync as jest.Mock).mockReturnValue([
        "sprout_backup_5.sqlite",
        "sprout_backup_4.sqlite",
        "sprout_backup_3.sqlite",
        "sprout_backup_2.sqlite",
        "sprout_backup_1.sqlite",
        "not_a_backup.txt" // Should be ignored
      ]);

      await (job as any).update();

      // Check Directory Creation
      expect(fs.existsSync).toHaveBeenCalledWith("/mock/backup/dir");
      expect(fs.mkdirSync).toHaveBeenCalledWith("/mock/backup/dir", { recursive: true });

      // Check File copy
      expect(fs.copyFileSync).toHaveBeenCalled();
      const copyArgs = (fs.copyFileSync as jest.Mock).mock.calls[0];
      expect(copyArgs[0]).toBe("/mock/db/sprout.sqlite");
      expect(copyArgs[1]).toMatch(/\/mock\/backup\/dir\/sprout_backup_.*\.sqlite/);

      // Check deletion of old files
      expect(fs.readdirSync).toHaveBeenCalledWith("/mock/backup/dir");
      // Since it sorts and filters, the top 3 will be kept (5, 4, 3), and bottom 2 (2, 1) deleted
      expect(fs.unlinkSync).toHaveBeenCalledTimes(2);
      expect(fs.unlinkSync).toHaveBeenCalledWith(expect.stringContaining("sprout_backup_2.sqlite"));
      expect(fs.unlinkSync).toHaveBeenCalledWith(expect.stringContaining("sprout_backup_1.sqlite"));
    });

    it("should not create directory if it already exists and not delete if under count", async () => {
      (fs.existsSync as jest.Mock).mockReturnValue(true);
      (fs.readdirSync as jest.Mock).mockReturnValue([
        "sprout_backup_1.sqlite",
      ]);

      await (job as any).update();

      expect(fs.mkdirSync).not.toHaveBeenCalled();
      expect(fs.copyFileSync).toHaveBeenCalled();
      expect(fs.unlinkSync).not.toHaveBeenCalled();
    });
  });
});
