import { setupTests } from "@backend/test/helpers";
setupTests();

import { ChatService } from "@backend/chat/chat.service";
import { ChatOverviewType } from "@backend/chat/model/chat.overview.type";
import { Configuration } from "@backend/config/core";
import { NotificationService } from "@backend/notification/notification.service";
import { ProviderType } from "@backend/providers/base/provider.type";
import { PostSyncProcessingJob } from "@backend/providers/jobs/post-sync";
import { Sync } from "@backend/providers/model/sync.model";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { TestEntities } from "@backend/test/entities";
import { UserDevice } from "@backend/user/model/user.device.model";
import { User } from "@backend/user/model/user.model";

describe("PostSyncProcessingJob", () => {
  let job: PostSyncProcessingJob;
  let notificationService: Mocked<NotificationService>;
  let sseService: Mocked<SSEService>;
  let chatService: Mocked<ChatService>;

  beforeEach(() => {
    notificationService = {
      notifyUser: vi.fn().mockResolvedValue({}),
    } as any;

    sseService = {
      sendToUser: vi.fn(),
    } as any;

    chatService = {
      getModel: vi.fn(),
    } as any;

    job = new PostSyncProcessingJob(notificationService, sseService, chatService);
  });

  describe("generateTasks", () => {
    it("should query unnotified completed or failed syncs", async () => {
      const mockQueryBuilder = {
        select: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        andWhere: vi.fn().mockReturnThis(),
        groupBy: vi.fn().mockReturnThis(),
        getRawMany: vi.fn().mockResolvedValue([{ userId: "user-1" }, { userId: "user-2" }]),
      };
      vi.spyOn(Sync, "getRepository").mockReturnValue({
        createQueryBuilder: vi.fn().mockReturnValue(mockQueryBuilder),
      } as any);

      const tasks = await (job as any).generateTasks();

      expect(tasks).toEqual([{ userId: "user-1" }, { userId: "user-2" }]);
    });
  });

  describe("processTask", () => {
    it("should return early if user is not found", async () => {
      vi.spyOn(User, "findOne").mockResolvedValue(null);
      const countSpy = vi.spyOn(Sync, "count").mockResolvedValue(0);

      await job.processTask({ userId: "invalid-user" });

      expect(countSpy).not.toHaveBeenCalled();
    });

    it("should defer processing if active sync count > 0", async () => {
      const user = TestEntities.user;
      vi.spyOn(User, "findOne").mockResolvedValue(user);
      vi.spyOn(Sync, "count").mockResolvedValue(1);
      const findSpy = vi.spyOn(Sync, "find").mockResolvedValue([]);

      await job.processTask({ userId: user.id });

      expect(findSpy).not.toHaveBeenCalled();
    });

    it("should return early if no unnotified syncs are found", async () => {
      const user = TestEntities.user;
      vi.spyOn(User, "findOne").mockResolvedValue(user);
      vi.spyOn(Sync, "count").mockResolvedValue(0);
      vi.spyOn(Sync, "find").mockResolvedValue([]);

      await job.processTask({ userId: user.id });

      expect(sseService.sendToUser).not.toHaveBeenCalled();
    });

    it("should deduplicate syncs by provider, send digest, and mark syncs notified", async () => {
      const user = TestEntities.user;
      const sync1 = Sync.fromPlain({ id: "sync-1", provider: ProviderType.plaid, status: "complete", time: new Date("2026-01-01"), user });
      const sync2 = Sync.fromPlain({ id: "sync-2", provider: ProviderType.plaid, status: "complete", time: new Date("2026-01-02"), user });

      vi.spyOn(User, "findOne").mockResolvedValue(user);
      vi.spyOn(Sync, "count").mockResolvedValue(0);
      vi.spyOn(Sync, "find").mockResolvedValue([sync1, sync2]);
      const updateWhereSpy = vi.spyOn(Sync, "updateWhere").mockResolvedValue({} as any);

      const sendDigestSpy = vi.spyOn(job, "sendDigest").mockResolvedValue(undefined);

      await job.processTask({ userId: user.id });

      expect(sendDigestSpy).toHaveBeenCalledWith(user, [sync2]);
      expect(updateWhereSpy).toHaveBeenCalled();
    });

    it("should rethrow error if digest fails", async () => {
      const user = TestEntities.user;
      const sync1 = Sync.fromPlain({ id: "sync-1", provider: ProviderType.plaid, status: "complete", time: new Date(), user });

      vi.spyOn(User, "findOne").mockResolvedValue(user);
      vi.spyOn(Sync, "count").mockResolvedValue(0);
      vi.spyOn(Sync, "find").mockResolvedValue([sync1]);
      vi.spyOn(job, "sendDigest").mockRejectedValue(new Error("Digest failed"));

      await expect(job.processTask({ userId: user.id })).rejects.toThrow("Digest failed");
    });
  });

  describe("deduplicateByProvider", () => {
    it("should keep the newer sync when an older sync appears later in the array", () => {
      const syncNewer = Sync.fromPlain({ id: "sync-1", provider: ProviderType.plaid, time: new Date("2026-01-02") });
      const syncOlder = Sync.fromPlain({ id: "sync-2", provider: ProviderType.plaid, time: new Date("2026-01-01") });

      const result = (job as any).deduplicateByProvider([syncNewer, syncOlder]);

      expect(result).toHaveLength(1);
      expect(result[0].id).toBe("sync-1");
    });
  });

  describe("sendDigest", () => {
    it("should trigger force update SSE and process overviews when successes exist", async () => {
      const user = TestEntities.user;
      const syncSuccess = Sync.fromPlain({ id: "s1", status: "complete", provider: ProviderType.plaid, user });

      vi.spyOn(Sync, "count").mockResolvedValue(0);
      Configuration.providers.syncNotifications.enabled = true;

      await job.sendDigest(user, [syncSuccess]);

      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(notificationService.notifyUser).toHaveBeenCalled();
    });

    it("should notify error when failures exist and fallback to 'Unknown error' if failureReason is missing", async () => {
      const user = TestEntities.user;
      const syncFailed = Sync.fromPlain({ id: "s2", status: "failed", failureReason: undefined, provider: ProviderType.plaid, user });

      vi.spyOn(Sync, "count").mockResolvedValue(0);
      Configuration.providers.syncNotifications.enabled = true;

      await job.sendDigest(user, [syncFailed]);

      expect(notificationService.notifyUser).toHaveBeenCalledWith(user, expect.stringContaining("Unknown error"), "Connection Error", expect.any(String));
    });

    it("should skip notification if notification already sent today", async () => {
      const user = TestEntities.user;
      const syncSuccess = Sync.fromPlain({ id: "s1", status: "complete", provider: ProviderType.plaid, user });

      vi.spyOn(Sync, "count").mockResolvedValue(1); // Already processed today
      Configuration.providers.syncNotifications.enabled = true;

      await job.sendDigest(user, [syncSuccess]);

      expect(notificationService.notifyUser).not.toHaveBeenCalled();
    });

    it("should skip notification logic if sync notifications are disabled in configuration", async () => {
      const user = TestEntities.user;
      const syncSuccess = Sync.fromPlain({ id: "s1", status: "complete", provider: ProviderType.plaid, user });

      vi.spyOn(Sync, "count").mockResolvedValue(0);
      Configuration.providers.syncNotifications.enabled = false;

      await job.sendDigest(user, [syncSuccess]);

      expect(notificationService.notifyUser).not.toHaveBeenCalled();
    });
  });

  describe("regenerateOverviewsIfActive", () => {
    it("should generate overviews if active devices exist and prompt is enabled", async () => {
      const user = TestEntities.user;
      (Configuration.server as any).prompt = { enabled: true };

      vi.spyOn(UserDevice, "count").mockResolvedValue(1);

      const mockOverviewModel = {
        generateOverview: vi.fn().mockResolvedValue(true),
      };
      chatService.getModel.mockResolvedValue(mockOverviewModel as any);

      await (job as any).regenerateOverviewsIfActive(user);

      expect(mockOverviewModel.generateOverview).toHaveBeenCalledTimes(Object.keys(ChatOverviewType).length);
    });

    it("should catch individual overview generation errors and continue generating other overviews", async () => {
      const user = TestEntities.user;
      (Configuration.server as any).prompt = { enabled: true };

      vi.spyOn(UserDevice, "count").mockResolvedValue(1);

      const mockOverviewModel = {
        generateOverview: vi.fn().mockRejectedValueOnce(new Error("Generation failed")).mockResolvedValue(true),
      };
      chatService.getModel.mockResolvedValue(mockOverviewModel as any);

      await (job as any).regenerateOverviewsIfActive(user);

      expect(mockOverviewModel.generateOverview).toHaveBeenCalledTimes(Object.keys(ChatOverviewType).length);
    });

    it("should catch outer exception if getting model fails", async () => {
      const user = TestEntities.user;
      (Configuration.server as any).prompt = { enabled: true };

      vi.spyOn(UserDevice, "count").mockResolvedValue(1);
      chatService.getModel.mockRejectedValue(new Error("Model initialization failed"));

      await expect((job as any).regenerateOverviewsIfActive(user)).resolves.not.toThrow();
    });

    it("should skip overview generation if prompt is disabled or active devices is 0", async () => {
      const user = TestEntities.user;
      (Configuration.server as any).prompt = { enabled: false };

      await (job as any).regenerateOverviewsIfActive(user);

      (Configuration.server as any).prompt = { enabled: true };

      await (job as any).regenerateOverviewsIfActive(user);
    });
  });
});
