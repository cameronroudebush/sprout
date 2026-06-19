import { setupTests } from "@backend/test/helpers";
setupTests();

import { Sync } from "@backend/jobs/model/sync.model";
import { ProviderSyncOrchestratorJob } from "@backend/jobs/sync";
import { ProviderBase } from "@backend/providers/base/core";
import { ProviderType } from "@backend/providers/base/provider.type";
import { ProviderSyncService } from "@backend/providers/base/sync.service";
import { User } from "@backend/user/model/user.model";

describe("ProviderSyncOrchestratorJob", () => {
  let orchestrator: ProviderSyncOrchestratorJob;
  let providerSyncService: jest.Mocked<ProviderSyncService>;
  let mockProvider1: any;
  let mockProvider2: any;
  let mockProviders: ProviderBase[];
  let mockUser: User;

  beforeEach(() => {
    jest.clearAllMocks();

    providerSyncService = {
      syncForProvider: jest.fn(),
    } as any;

    mockProvider1 = {
      config: { dbType: ProviderType.plaid },
      getAppConfiguration: jest.fn().mockReturnValue({ syncFrequency: "0 0 * * *", enabled: true }),
    };

    mockProvider2 = {
      config: { dbType: ProviderType.plaid },
      getAppConfiguration: jest.fn().mockReturnValue({ syncFrequency: "0 1 * * *", enabled: false }),
    };

    mockProviders = [mockProvider1, mockProvider2];
    mockUser = User.fromPlain({ id: "user-abc" }) as User;

    orchestrator = new ProviderSyncOrchestratorJob(providerSyncService, mockProviders);
  });

  describe("onApplicationBootstrap", () => {
    it("should instantiate and start a ProviderSyncJob wrapper around each provided base instance", async () => {
      await orchestrator.onApplicationBootstrap();

      expect(orchestrator.jobs.length).toBe(2);
    });
  });

  describe("syncUserAllProviders", () => {
    it("should fan out task requests across all registered internal job execution threads", async () => {
      await orchestrator.onApplicationBootstrap();

      const processTaskSpy = jest.spyOn(orchestrator.jobs[0]!, "processTask").mockResolvedValue({} as any);
      jest.spyOn(orchestrator.jobs[1]!, "processTask").mockResolvedValue({} as any);

      await orchestrator.syncUserAllProviders(mockUser, false);

      expect(processTaskSpy).toHaveBeenCalledWith({ userId: "user-abc", notify: false });
    });
  });

  describe("syncUserSingleProvider", () => {
    it("should match target jobs by engine profile signatures and invoke processing parameters exclusively", async () => {
      await orchestrator.onApplicationBootstrap();

      const targetSpy = jest.spyOn(orchestrator.jobs[0]!, "processTask").mockResolvedValue({ status: "ok" } as any);
      const skippedSpy = jest.spyOn(orchestrator.jobs[1]!, "processTask");

      const result = await orchestrator.syncUserSingleProvider(mockUser, ProviderType.plaid, false);

      expect(targetSpy).toHaveBeenCalledWith({ userId: "user-abc", notify: false });
      expect(skippedSpy).not.toHaveBeenCalled();
      expect(result).toEqual({ status: "ok" });
    });

    it("should throw a standard Error description when no matching profile runner handles the requested target", async () => {
      await orchestrator.onApplicationBootstrap();

      await expect(orchestrator.syncUserSingleProvider(mockUser, "non-existent-provider" as ProviderType, false)).rejects.toThrow(
        new Error("Sync job runner for provider type 'non-existent-provider' was not found or is disabled."),
      );
    });
  });

  describe("ProviderSyncJob (Internal Framework)", () => {
    describe("generateTasks", () => {
      it("should trigger history cleanups map user entities into flat task distribution dictionaries", async () => {
        await orchestrator.onApplicationBootstrap();
        const instance = orchestrator.jobs[0];

        const cleanupSpy = jest.spyOn(instance as any, "cleanupOldSyncs").mockResolvedValue(undefined);
        const findSpy = jest.spyOn(User, "find").mockResolvedValue([User.fromPlain({ id: "u1" }), User.fromPlain({ id: "u2" })]);

        const result = await (instance as any).generateTasks();

        expect(cleanupSpy).toHaveBeenCalled();
        expect(findSpy).toHaveBeenCalledWith({ select: { id: true } });
        expect(result).toEqual([{ userId: "u1" }, { userId: "u2" }]);
      });
    });

    describe("processTask", () => {
      it("should fetch active profiles from structural lookup and invoke backend operational sync methods", async () => {
        await orchestrator.onApplicationBootstrap();
        const instance = orchestrator.jobs[0]!;

        const findOneSpy = jest.spyOn(User, "findOne").mockResolvedValue(mockUser);
        providerSyncService.syncForProvider.mockResolvedValue({ status: "synced" } as any);

        const result = await instance.processTask({ userId: "user-abc", notify: false });

        expect(findOneSpy).toHaveBeenCalledWith({ where: { id: "user-abc" } });
        expect(providerSyncService.syncForProvider).toHaveBeenCalledWith(mockUser, instance.provider, false);
        expect(result).toEqual({ status: "synced" });
      });

      it("should gracefully return early if database search queries return empty matching users", async () => {
        await orchestrator.onApplicationBootstrap();
        const instance = orchestrator.jobs[0]!;

        jest.spyOn(User, "findOne").mockResolvedValue(null);

        const result = await instance.processTask({ userId: "user-missing" });

        expect(providerSyncService.syncForProvider).not.toHaveBeenCalled();
        expect(result).toBeUndefined();
      });
    });

    describe("cleanupOldSyncs", () => {
      it("should process structural storage cleanups up to predefined target day configurations", async () => {
        await orchestrator.onApplicationBootstrap();
        const instance = orchestrator.jobs[0];

        jest.useFakeTimers().setSystemTime(new Date("2026-06-02T12:00:00.000Z"));

        const deleteSpy = jest.spyOn(Sync, "delete").mockResolvedValue({ affected: 15 } as any);
        const logSpy = jest.spyOn((instance as any).logger, "log");

        await (instance as any).cleanupOldSyncs();

        expect(deleteSpy).toHaveBeenCalledWith({
          time: expect.any(Object),
          provider: ProviderType.plaid,
        });
        expect(logSpy).toHaveBeenCalledWith("Removed 15 old sync record(s).");

        jest.useRealTimers();
      });

      it("should catch and log standard exception parameters without escalating errors up call contexts", async () => {
        await orchestrator.onApplicationBootstrap();
        const instance = orchestrator.jobs[0];

        jest.spyOn(Sync, "delete").mockRejectedValue(new Error("Database connection timeout"));
        const errorSpy = jest.spyOn((instance as any).logger, "error");

        await expect((instance as any).cleanupOldSyncs(60)).resolves.not.toThrow();
        expect(errorSpy).toHaveBeenCalledWith("Failed to cleanup old sync records: Database connection timeout");
      });

      it("should skip emitting telemetry logs if standard delete operational outcomes report zero affected records", async () => {
        await orchestrator.onApplicationBootstrap();
        const instance = orchestrator.jobs[0];

        jest.spyOn(Sync, "delete").mockResolvedValue({ affected: 0 } as any);
        const logSpy = jest.spyOn((instance as any).logger, "log");

        await (instance as any).cleanupOldSyncs();

        expect(logSpy).toHaveBeenCalledTimes(3);
      });
    });
  });
});
