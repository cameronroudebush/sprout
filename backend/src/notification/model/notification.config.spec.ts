import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { FirebaseConfig, NotificationConfig } from "@backend/notification/model/notification.config.js";

describe("NotificationConfig", () => {
  it("should validate FirebaseConfig when disabled", () => {
    const config = new FirebaseConfig();
    config.enabled = false;
    expect(() => config.validate()).not.toThrow();
  });

  it("should validate FirebaseConfig required fields when enabled", () => {
    const config = new FirebaseConfig();
    config.enabled = true;

    expect(() => config.validate()).toThrow("Firebase config: API key must be defined for usage.");

    config.apiKey = "key";
    expect(() => config.validate()).toThrow("Firebase config: App ID must be defined for usage.");

    config.appId = "app";
    expect(() => config.validate()).toThrow("Firebase config: Message Sender ID must be defined for usage.");

    config.projectNumber = 123;
    expect(() => config.validate()).toThrow("Firebase config: Project ID must be defined for usage.");

    config.projectId = "proj";
    expect(() => config.validate()).toThrow("Firebase config: Client email must be defined for usage.");

    config.clientEmail = "email@test.com";
    expect(() => config.validate()).toThrow("Firebase config: Private Key must be defined for usage.");

    config.privateKey = "privKey";
    expect(() => config.validate()).not.toThrow();
  });

  it("should instantiate NotificationConfig", () => {
    const notifConfig = new NotificationConfig();
    expect(notifConfig.maxNotificationsPerUser).toBe(10);
    expect(notifConfig.firebase).toBeInstanceOf(FirebaseConfig);
  });
});
