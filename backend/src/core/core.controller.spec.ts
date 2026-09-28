import { setupTests } from "@backend/test/helpers";
setupTests();

import { CoreController } from "@backend/core/core.controller";
import { CoreService } from "@backend/core/core.service";
import { DatabaseBackupJob } from "@backend/core/jobs/backup";
import { TestEntities } from "@backend/test/entities";

describe("CoreController", () => {
  let controller: CoreController;
  let mockDatabaseBackupJob: Partial<DatabaseBackupJob>;
  let mockCoreService: Partial<CoreService>;

  beforeEach(() => {
    vi.clearAllMocks();
    mockDatabaseBackupJob = {
      getBackupSummary: vi.fn().mockReturnValue({
        totalCount: 0,
        totalSizeBytes: 0,
        backups: [],
      }),
    };
    mockCoreService = { getAdminDashboard: vi.fn().mockResolvedValue("<html>admin</html>") };

    controller = new CoreController(mockDatabaseBackupJob as DatabaseBackupJob, mockCoreService as CoreService);
  });

  describe("heartbeat", () => {
    it("should return heartbeat message", async () => {
      const result = await controller.heartbeat();
      expect(result).toBe("Sprout is alive!");
    });
  });

  describe("adminDashboard", () => {
    it("should delegate dashboard rendering to CoreService", async () => {
      const user = TestEntities.adminUser;

      await expect(controller.adminDashboard(user, "https://sprout.example")).resolves.toBe("<html>admin</html>");
      expect(mockCoreService.getAdminDashboard).toHaveBeenCalledWith(user, "https://sprout.example");
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
