import { setupTests } from "@backend/test/helpers";
setupTests();

import { TestEntities } from "@backend/test/entities";
import { UserDevice } from "@backend/user/model/user.device.model";
import { DevicePlatform } from "@backend/user/model/user.device.type";

describe("UserDevice model", () => {
  it("should create instance with constructor parameters", () => {
    const user = TestEntities.user;
    const device = new UserDevice(user, "dev-123", "fcm-tok", DevicePlatform.IOS, "iPhone");

    expect(device.user).toBe(user);
    expect(device.deviceId).toBe("dev-123");
    expect(device.fcmToken).toBe("fcm-tok");
    expect(device.platform).toBe(DevicePlatform.IOS);
    expect(device.deviceName).toBe("iPhone");
  });
});
