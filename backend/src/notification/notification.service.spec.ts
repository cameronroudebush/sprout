import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { Configuration } from "@backend/config/core.js";
import { Notification } from "@backend/notification/model/notification.model.js";
import { NotificationType } from "@backend/notification/model/notification.type.js";
import { NotificationService } from "@backend/notification/notification.service.js";
import { SSEEventType } from "@backend/sse/model/event.model.js";
import { SSEService } from "@backend/sse/sse.service.js";
import { TestEntities } from "@backend/test/entities.js";
import { UserDevice } from "@backend/user/model/user.device.model.js";
import { initializeApp } from "firebase-admin/app";

vi.mock("firebase-admin/app", () => ({
  initializeApp: vi.fn().mockReturnValue({}),
  cert: vi.fn().mockReturnValue({}),
}));

const mockSend = vi.fn();
vi.mock("firebase-admin/messaging", () => ({
  getMessaging: vi.fn().mockReturnValue({
    send: (...args: any[]) => mockSend(...args),
  }),
}));

describe("NotificationService", () => {
  let service: NotificationService;
  let sseService: Mocked<SSEService>;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.clearAllMocks();

    sseService = {
      sendToUser: vi.fn(),
    } as unknown as Mocked<SSEService>;

    service = new NotificationService(sseService);
  });

  describe("onModuleInit", () => {
    it("should initialize firebase app if enabled", () => {
      const origEnabled = Configuration.server.notification.firebase.enabled;
      Configuration.server.notification.firebase.enabled = true;

      vi.spyOn(Configuration.server.notification.firebase, "validate").mockReturnValue();

      service.onModuleInit();
      expect(initializeApp).toHaveBeenCalled();

      Configuration.server.notification.firebase.enabled = origEnabled;
    });

    it("should do nothing if firebase is disabled", () => {
      const origEnabled = Configuration.server.notification.firebase.enabled;
      Configuration.server.notification.firebase.enabled = false;

      service.onModuleInit();

      Configuration.server.notification.firebase.enabled = origEnabled;
    });
  });

  describe("notifyUser & notifyApp & cleanupUserMax", () => {
    it("should insert notification, cleanup max limit, send SSE, and notify app", async () => {
      vi.spyOn(Notification.prototype, "insert").mockImplementation(async function (this: Notification) {
        this.id = "n-123";
        return this;
      });

      const n1 = TestEntities.notification;
      const n2 = TestEntities.notification;
      vi.spyOn(Notification, "find").mockResolvedValue([n1, n2]);
      vi.spyOn(Notification, "deleteMany").mockResolvedValue({} as any);

      Configuration.server.notification.maxNotificationsPerUser = 1;

      const result = await service.notifyUser(user, "Test Message", "Test Title", NotificationType.info, false);

      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.NOTIFICATION, expect.anything());
      expect(Notification.deleteMany).toHaveBeenCalled();
      expect(result.title).toBe("Test Title");
    });

    it("should notify devices via Firebase Messaging when enabled and handle non-registration errors", async () => {
      Configuration.server.notification.firebase.enabled = true;

      const devWithToken = new UserDevice(user, "dev-1", "fcm-123", "android" as any, "Phone 1");
      const devNoToken = new UserDevice(user, "dev-2", undefined, "android" as any, "Phone 2");

      vi.spyOn(UserDevice, "find").mockResolvedValue([devWithToken, devNoToken]);
      mockSend.mockResolvedValue("msg-id");

      const n = TestEntities.notification;
      await (service as unknown as { notifyApp: (u: unknown, n: unknown) => Promise<void> }).notifyApp(user, n);

      expect(mockSend).toHaveBeenCalled();

      // Test error handling in notifyApp (registration-token-not-registered)
      mockSend.mockRejectedValueOnce({ code: "messaging/registration-token-not-registered" });
      vi.spyOn(UserDevice, "delete").mockResolvedValue({} as any);

      await (service as unknown as { notifyApp: (u: unknown, n: unknown) => Promise<void> }).notifyApp(user, n);
      expect(UserDevice.delete).toHaveBeenCalledWith({ fcmToken: "fcm-123" });

      // Test generic error handling in notifyApp
      const loggerSpy = vi.spyOn((service as unknown as { logger: { error: (e: unknown) => void } }).logger, "error");
      mockSend.mockRejectedValueOnce(new Error("Generic messaging error"));
      await (service as unknown as { notifyApp: (u: unknown, n: unknown) => Promise<void> }).notifyApp(user, n);
      expect(loggerSpy).toHaveBeenCalled();

      Configuration.server.notification.firebase.enabled = false;
    });

    it("should handle empty device list in notifyApp", async () => {
      Configuration.server.notification.firebase.enabled = true;
      vi.spyOn(UserDevice, "find").mockResolvedValue([]);

      const n = TestEntities.notification;
      await (service as unknown as { notifyApp: (u: unknown, n: unknown) => Promise<void> }).notifyApp(user, n);

      Configuration.server.notification.firebase.enabled = false;
    });

    it("should notify app through disabled Firebase path without sending", async () => {
      Configuration.server.notification.firebase.enabled = false;
      vi.spyOn(Notification.prototype, "insert").mockResolvedValue(TestEntities.notification);
      vi.spyOn(Notification, "find").mockResolvedValue([]);

      await service.notifyUser(user, "message", "title", NotificationType.info, true);

      expect(mockSend).not.toHaveBeenCalled();
    });
  });
});
