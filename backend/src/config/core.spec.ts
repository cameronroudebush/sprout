import { setupTests } from "@backend/test/helpers.js";
setupTests();
vi.doUnmock("@backend/config/core");

describe("Configuration Core", () => {
  it("should return static application name and default options", async () => {
    const originalDevBuild = process.env.IS_DEV_BUILD;
    process.env.IS_DEV_BUILD = "false";
    const { Configuration } = await import("./core.ts");
    try {
      expect(Configuration.appName).toBe("sprout");
      expect(Configuration.isDevBuild).toBe("false");
      expect(Configuration.providers).toBeDefined();
      expect(Configuration.server).toBeDefined();
      expect(Configuration.database).toBeDefined();
      expect(Configuration.transaction).toBeDefined();
      expect(Configuration.holding).toBeDefined();
      expect(Configuration.user).toBeDefined();
    } finally {
      if (originalDevBuild === undefined) delete process.env.IS_DEV_BUILD;
      else process.env.IS_DEV_BUILD = originalDevBuild;
    }
  });
});
