import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { Configuration } from "@backend/config/core.js";
import { FirebaseConfigDTO } from "@backend/notification/model/api/firebase.config.dto.js";
import { InternalServerErrorException } from "@nestjs/common";

describe("FirebaseConfigDTO", () => {
  let originalFirebaseConfig: any;

  beforeEach(() => {
    originalFirebaseConfig = { ...Configuration.server.notification.firebase };
  });

  afterEach(() => {
    Object.assign(Configuration.server.notification.firebase, originalFirebaseConfig);
  });

  it("should construct properly with constructor arguments", () => {
    const config = new FirebaseConfigDTO("key-1", "app-1", "num-1", "proj-1");

    expect(config.apiKey).toBe("key-1");
    expect(config.appId).toBe("app-1");
    expect(config.projectNumber).toBe("num-1");
    expect(config.projectId).toBe("proj-1");
  });

  it("should return undefined fromConfig when firebase is disabled", () => {
    Configuration.server.notification.firebase.enabled = false;
    expect(FirebaseConfigDTO.fromConfig()).toBeUndefined();
  });

  it("should return FirebaseConfigDTO fromConfig when firebase is valid and enabled", () => {
    Configuration.server.notification.firebase.enabled = true;
    Configuration.server.notification.firebase.apiKey = "api-key";
    Configuration.server.notification.firebase.appId = "app-id";
    Configuration.server.notification.firebase.projectNumber = 12345;
    Configuration.server.notification.firebase.projectId = "proj-id";
    Configuration.server.notification.firebase.clientEmail = "email@test.com";
    Configuration.server.notification.firebase.privateKey = "priv-key";
    vi.mocked(Configuration.server.notification.firebase.validate).mockImplementation(() => {});

    const dto = FirebaseConfigDTO.fromConfig();
    expect(dto).toBeDefined();
    expect(dto?.apiKey).toBe("api-key");
    expect(dto?.appId).toBe("app-id");
    expect(dto?.projectNumber).toBe("12345");
    expect(dto?.projectId).toBe("proj-id");
  });

  it("should throw InternalServerErrorException fromConfig when validation fails", () => {
    Configuration.server.notification.firebase.enabled = true;
    vi.mocked(Configuration.server.notification.firebase.validate).mockImplementationOnce(() => {
      throw new Error("Validation failed");
    });

    expect(() => FirebaseConfigDTO.fromConfig()).toThrow(InternalServerErrorException);
  });
});
