import { setupTests } from "@backend/test/helpers";
setupTests();

import { Notification } from "@backend/notification/model/notification.model";
import { NotificationType } from "@backend/notification/model/notification.type";
import { TestEntities } from "@backend/test/entities";

describe("Notification Model", () => {
  const user = TestEntities.user;

  it("should create notification instance with type and importance", () => {
    const notif = new Notification(user, "Alert Title", "Alert Message", NotificationType.error);

    expect(notif.title).toBe("Alert Title");
    expect(notif.message).toBe("Alert Message");
    expect(notif.type).toBe(NotificationType.error);
    expect(notif.user).toBe(user);
    expect(notif.importance).toBe("high");
    expect(notif.powerPriority).toBe("high");
  });

  it("should calculate default importance for info and success notifications", () => {
    const notif = new Notification(user, "Info Title", "Info Message", NotificationType.info);
    expect(notif.importance).toBe("default");
    expect(notif.powerPriority).toBe("normal");

    const successNotif = new Notification(user, "Success Title", "Success Message", NotificationType.success);
    expect(successNotif.importance).toBe("default");
    expect(successNotif.powerPriority).toBe("normal");

    const warnNotif = new Notification(user, "Warn Title", "Warn Message", NotificationType.warning);
    expect(warnNotif.importance).toBe("high");
    expect(warnNotif.powerPriority).toBe("high");
  });
});
