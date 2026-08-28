import { setupTests } from "@backend/test/helpers";
setupTests();

import { Configuration } from "@backend/config/core";
import { Notification } from "@backend/notification/model/notification.model";
import { NotificationController } from "@backend/notification/notification.controller";
import { NotificationService } from "@backend/notification/notification.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { TestEntities } from "@backend/test/entities";

describe("NotificationController", () => {
  let controller: NotificationController;
  let sseService: jest.Mocked<SSEService>;
  let notificationService: jest.Mocked<NotificationService>;
  const user = TestEntities.user;

  beforeEach(() => {
    sseService = {
      sendToUser: jest.fn(),
    } as any;

    notificationService = {
      notifyUser: jest.fn().mockResolvedValue({}),
    } as any;

    (Configuration as any).server = {
      notification: {
        firebase: {
          enabled: false,
        },
      },
    };

    controller = new NotificationController(sseService, notificationService);
  });

  describe("getNotifications", () => {
    it("should return notifications for current user ordered by createdAt DESC", async () => {
      const notifications = [TestEntities.notification];
      jest.spyOn(Notification, "find").mockResolvedValue(notifications);

      const res = await controller.getNotifications(user);

      expect(Notification.find).toHaveBeenCalledWith({
        where: { user: { id: user.id } },
        order: { createdAt: "DESC" },
      });
      expect(res).toBe(notifications);
    });
  });

  describe("markAllRead", () => {
    it("should update all notifications to read and send SSE notification event", async () => {
      const updateWhereSpy = jest.spyOn(Notification, "updateWhere").mockResolvedValue({} as any);

      await controller.markAllRead(user);

      expect(updateWhereSpy).toHaveBeenCalledWith({ user: { id: user.id } }, expect.objectContaining({ isRead: true }));
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.NOTIFICATION, expect.anything());
    });
  });

  describe("markRead", () => {
    it("should update single notification to read and send SSE notification event", async () => {
      const updateWhereSpy = jest.spyOn(Notification, "updateWhere").mockResolvedValue({} as any);

      await controller.markRead("note-1", user);

      expect(updateWhereSpy).toHaveBeenCalledWith({ id: "note-1", user: { id: user.id } }, expect.objectContaining({ isRead: true }));
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.NOTIFICATION, expect.anything());
    });
  });

  describe("getFirebaseConfig", () => {
    it("should return undefined when firebase notification is disabled", () => {
      Configuration.server.notification.firebase.enabled = false;

      const config = controller.getFirebaseConfig();

      expect(config).toBeUndefined();
    });
  });

  describe("getById", () => {
    it("should find notification by id for current user", async () => {
      const notification = TestEntities.notification;
      jest.spyOn(Notification, "findOne").mockResolvedValue(notification);

      const res = await controller.getById(notification.id, user);

      expect(Notification.findOne).toHaveBeenCalledWith({ where: { id: notification.id, user: { id: user.id } } });
      expect(res).toBe(notification);
    });
  });

  describe("notify", () => {
    it("should call notificationService.notifyUser with test message", async () => {
      await controller.notify(user);

      expect(notificationService.notifyUser).toHaveBeenCalledWith(user, "This is a test of the notification pipeline", "Test notification", expect.anything());
    });
  });
});
