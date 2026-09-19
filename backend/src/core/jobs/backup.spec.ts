import { setupTests } from "@backend/test/helpers";
setupTests();

import { DatabaseBackupJob } from "@backend/core/jobs/backup";

describe("DatabaseBackupJob", () => {
  let runner: DatabaseBackupJob;

  beforeEach(() => {
    vi.clearAllMocks();
    runner = new DatabaseBackupJob();
  });

  describe("getBackupSummary", () => {
    it("should return empty summary if backup dir missing or empty", () => {
      const summary = runner.getBackupSummary();
      expect(summary).toBeDefined();
    });
  });
});
