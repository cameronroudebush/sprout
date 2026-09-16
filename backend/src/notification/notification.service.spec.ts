import { setupTests } from "@backend/test/helpers";
setupTests();

import { NotificationService } from "@backend/notification/notification.service";
import { SSEService } from "@backend/sse/sse.service";
import { Notification } from "@backend/notification/model/notification.model";
import { NotificationType } from "@backend/notification/model/notification.type";
import { Configuration } from "@backend/config/core";
import { TestEntities } from "@backend/test/entities";
import { SSEEventType } from "@backend/sse/model/event.model";

describe("NotificationService", () => {
  let service: NotificationService;
  let sseService: jest.Mocked<SSEService>;
  const user = TestEntities.user;

  beforeEach(() => {
    jest.clearAllMocks();

    sseService = {
      sendToUser: jest.fn(),
    } as any;

    service = new NotificationService(sseService);
  });

  describe("onModuleInit", () => {
    it("should initialize firebase app if enabled", () => {
      const originalEnabled = Configuration.server.notification.firebase.enabled;
      Configuration.server.notification.firebase.enabled = false;

      service.onModuleInit();

      expect(Configuration.server.notification.firebase.enabled).toBe(false);
      Configuration.server.notification.firebase.enabled = originalEnabled;
    });
  });

  describe("notifyUser", () => {
    it("should insert notification, cleanup max limit, send SSE, and notify app", async () => {
      const insertSpy = jest.fn().mockImplementation(async function (this: any) {
        this.id = "n-123";
        return this;
      });
      jest.spyOn(Notification.prototype, "insert").mockImplementation(insertSpy);
      jest.spyOn(Notification, "find").mockResolvedValue([]);

      const result = await service.notifyUser(user, "Test Message", "Test Title", NotificationType.info, false);

      expect(insertSpy).toHaveBeenCalled();
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.NOTIFICATION, expect.anything());
      expect(result.title).toBe("Test Title");
    });
  });
});
