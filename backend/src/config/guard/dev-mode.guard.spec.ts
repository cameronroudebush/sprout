import { setupTests } from "@backend/test/helpers";
setupTests();

import { Configuration } from "@backend/config/core";
import { DevModeGuard } from "@backend/config/guard/dev-mode.guard";
import { NotFoundException } from "@nestjs/common";

describe("DevModeGuard", () => {
  let guard: DevModeGuard;
  const originalIsDevBuild = Configuration.isDevBuild;
  const originalIsRunningScript = Configuration.isRunningScript;

  beforeEach(() => {
    vi.clearAllMocks();
    guard = new DevModeGuard();
  });

  afterEach(() => {
    Configuration.isDevBuild = originalIsDevBuild;
    Configuration.isRunningScript = originalIsRunningScript;
  });

  describe("canActivate", () => {
    it("should return true when Configuration.isDevBuild is true", () => {
      Configuration.isDevBuild = true;
      expect(guard.canActivate()).toBe(true);
    });

    it("should throw NotFoundException when Configuration.isDevBuild is false", () => {
      Configuration.isDevBuild = false;
      expect(() => guard.canActivate()).toThrow(NotFoundException);
    });
  });

  describe("attach", () => {
    it("should attach guard to endpoint when descriptor and propertyKey are provided", () => {
      Configuration.isDevBuild = false;
      Configuration.isRunningScript = false;

      const target = {};
      const descriptor = { value: vi.fn() };
      const decorator = DevModeGuard.attach();

      decorator(target, "testProperty", descriptor);
    });

    it("should attach guard to controller when descriptor is not provided", () => {
      Configuration.isDevBuild = false;
      Configuration.isRunningScript = false;

      class TestController {}
      const decorator = DevModeGuard.attach();

      decorator(TestController);
    });

    it("should skip documentation exclusion if Configuration.isDevBuild is true", () => {
      Configuration.isDevBuild = true;
      Configuration.isRunningScript = false;

      class TestController {}
      const decorator = DevModeGuard.attach();

      decorator(TestController);
    });
  });
});
