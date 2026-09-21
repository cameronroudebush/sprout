import { setupTests } from "@backend/test/helpers";
setupTests();

import { FirebaseNotificationDTO } from "@backend/notification/model/api/firebase.notification.dto";

describe("FirebaseNotificationDTO", () => {
  it("should construct from plain object", () => {
    const dto = new FirebaseNotificationDTO({
      notificationId: "n-123",
      importance: "high",
    });

    expect(dto.notificationId).toBe("n-123");
    expect(dto.importance).toBe("high");
  });
});
