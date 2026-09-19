import { setupTests } from "@backend/test/helpers";
setupTests();

import { ProviderBase } from "@backend/providers/base/core";
import { ProviderType } from "@backend/providers/base/provider.type";
import { ProviderSyncService } from "@backend/providers/base/sync.service";
import { ProviderSyncJob } from "@backend/providers/jobs/sync";
import { Sync } from "@backend/providers/model/sync.model";
import { SyncTriggerType } from "@backend/providers/model/sync.type";
import { User } from "@backend/user/model/user.model";

describe("ProviderSyncJob", () => {
  let job: ProviderSyncJob;
  let providerSyncService: Mocked<ProviderSyncService>;
  let mockProvider: ProviderBase;
  let mockUser: User;

  beforeEach(() => {
    vi.clearAllMocks();

    providerSyncService = {
      syncForProvider: vi.fn(),
    } as any;

    mockProvider = {
      config: { dbType: ProviderType.plaid },
      getAppConfiguration: vi.fn().mockReturnValue({
        syncFrequency: "0 0 * * *",
        enabled: true,
      }),
    } as any;

    mockUser = User.fromPlain({ id: "user-abc" }) as User;

    job = new ProviderSyncJob(mockProvider, providerSyncService);

    // Ensure logger exists on instance for spy coverage
    (job as any).logger = {
      log: vi.fn(),
      error: vi.fn(),
    };
  });

  describe("constructor", () => {
    it("should initialize with correct provider configuration", () => {
      expect(job.provider).toBe(mockProvider);
      expect(mockProvider.getAppConfiguration).toHaveBeenCalled();
    });
  });

  describe("generateTasks", () => {
    it("should execute cleanup and return mapped user task payloads", async () => {
      const cleanupSpy = vi.spyOn(job as any, "cleanupOldSyncs").mockResolvedValue(undefined);
      const findSpy = vi.spyOn(User, "find").mockResolvedValue([User.fromPlain({ id: "u1" }) as User, User.fromPlain({ id: "u2" }) as User]);

      const result = await (job as any).generateTasks();

      expect(cleanupSpy).toHaveBeenCalled();
      expect(findSpy).toHaveBeenCalledWith({ select: { id: true } });
      expect(result).toEqual([{ userId: "u1" }, { userId: "u2" }]);
    });
  });

  describe("processTask", () => {
    it("should fetch user and invoke providerSyncService", async () => {
      const findOneSpy = vi.spyOn(User, "findOne").mockResolvedValue(mockUser);
      providerSyncService.syncForProvider.mockResolvedValue({ status: "synced" } as any);

      const result = await job.processTask({ userId: "user-abc" });

      expect(findOneSpy).toHaveBeenCalledWith({ where: { id: "user-abc" } });
      expect(providerSyncService.syncForProvider).toHaveBeenCalledWith(mockUser, mockProvider, SyncTriggerType.SCHEDULED);
      expect(result).toEqual({ status: "synced" });
    });

    it("should return early if user is not found in database", async () => {
      vi.spyOn(User, "findOne").mockResolvedValue(null);

      const result = await job.processTask({ userId: "user-missing" });

      expect(providerSyncService.syncForProvider).not.toHaveBeenCalled();
      expect(result).toBeUndefined();
    });
  });

  describe("cleanupOldSyncs", () => {
    beforeEach(() => {
      vi.useFakeTimers().setSystemTime(new Date("2026-06-02T12:00:00.000Z"));
    });

    afterEach(() => {
      vi.useRealTimers();
    });

    it("should delete old sync records and log affected count when > 0", async () => {
      const deleteSpy = vi.spyOn(Sync, "delete").mockResolvedValue({ affected: 15 } as any);
      const logSpy = vi.spyOn((job as any).logger, "log");

      await (job as any).cleanupOldSyncs();

      expect(deleteSpy).toHaveBeenCalledWith({
        time: expect.any(Object),
        provider: ProviderType.plaid,
      });
      expect(logSpy).toHaveBeenCalledWith("Removed 15 old sync record(s).");
    });

    it("should skip log emission when affected count is 0 or undefined", async () => {
      vi.spyOn(Sync, "delete").mockResolvedValue({ affected: 0 } as any);
      const logSpy = vi.spyOn((job as any).logger, "log");

      await (job as any).cleanupOldSyncs();

      expect(logSpy).not.toHaveBeenCalled();
    });

    it("should catch and log error on database failure without throwing", async () => {
      vi.spyOn(Sync, "delete").mockRejectedValue(new Error("Database connection timeout"));
      const errorSpy = vi.spyOn((job as any).logger, "error");

      await expect((job as any).cleanupOldSyncs(60)).resolves.not.toThrow();
      expect(errorSpy).toHaveBeenCalledWith("Failed to cleanup old sync records: Database connection timeout");
    });
  });
});
