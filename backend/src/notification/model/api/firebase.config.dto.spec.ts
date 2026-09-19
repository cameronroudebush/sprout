import { setupTests } from "@backend/test/helpers";
setupTests();

import { FirebaseConfigDTO } from "@backend/notification/model/api/firebase.config.dto";

describe("FirebaseConfigDTO", () => {
  it("should construct properly with constructor arguments", () => {
    const config = new FirebaseConfigDTO("key-1", "app-1", "num-1", "proj-1");

    expect(config.apiKey).toBe("key-1");
    expect(config.appId).toBe("app-1");
    expect(config.projectId).toBe("proj-1");
  });
});
