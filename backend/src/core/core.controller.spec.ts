import { setupTests } from "@backend/test/helpers";
setupTests();

import { CoreController } from "@backend/core/core.controller";
import { DatabaseBackupJob } from "@backend/core/jobs/backup";

describe("CoreController", () => {
  let controller: CoreController;
  let mockDatabaseBackupJob: Partial<DatabaseBackupJob>;

  beforeEach(() => {
    mockDatabaseBackupJob = {
      getBackupSummary: jest.fn().mockReturnValue({
        totalCount: 0,
        totalSizeBytes: 0,
        backups: [],
      }),
    };

    controller = new CoreController(mockDatabaseBackupJob as DatabaseBackupJob);
  });

  describe("heartbeat", () => {
    it("should return heartbeat message", async () => {
      const result = await controller.heartbeat();
      expect(result).toBe("Sprout is alive!");
    });
  });

  describe("getBackups", () => {
    it("should return backup summary data", async () => {
      const result = await controller.getBackups();
      expect(result).toEqual({
        totalCount: 0,
        totalSizeBytes: 0,
        backups: [],
      });
      expect(mockDatabaseBackupJob.getBackupSummary).toHaveBeenCalled();
    });
  });
});
