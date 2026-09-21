import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { Configuration } from "@backend/config/core.js";

describe("Configuration Core", () => {
  it("should return static application name and default options", () => {
    expect(Configuration.appName).toBe("sprout");
    expect(Configuration.isDevBuild).toBeDefined();
    expect(Configuration.providers).toBeDefined();
    expect(Configuration.server).toBeDefined();
    expect(Configuration.database).toBeDefined();
    expect(Configuration.transaction).toBeDefined();
    expect(Configuration.holding).toBeDefined();
    expect(Configuration.user).toBeDefined();
  });
});
