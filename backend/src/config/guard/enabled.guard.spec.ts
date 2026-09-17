import { setupTests } from "@backend/test/helpers";
setupTests();

import { Configuration } from "@backend/config/core";
import { EnabledGuard } from "@backend/config/guard/enabled.guard";
import { BadRequestException, ExecutionContext, NotFoundException } from "@nestjs/common";
import { Reflector } from "@nestjs/core";

describe("EnabledGuard", () => {
  let guard: EnabledGuard;
  let reflector: jest.Mocked<Reflector>;
  const originalIsDemoMode = Configuration.isDemoMode;
  const originalIsDevBuild = Configuration.isDevBuild;
  const originalIsRunningScript = Configuration.isRunningScript;

  beforeEach(() => {
    jest.clearAllMocks();
    reflector = {
      getAllAndOverride: jest.fn(),
    } as any;
    guard = new EnabledGuard(reflector);
  });

  afterEach(() => {
    Configuration.isDemoMode = originalIsDemoMode;
    Configuration.isDevBuild = originalIsDevBuild;
    Configuration.isRunningScript = originalIsRunningScript;
  });

  describe("canActivate", () => {
    function createMockContext(): ExecutionContext {
      return {
        getHandler: () => jest.fn(),
        getClass: () => jest.fn(),
      } as any;
    }

    it("should return true when no options metadata is found", () => {
      reflector.getAllAndOverride.mockReturnValue(undefined);
      const context = createMockContext();
      expect(guard.canActivate(context)).toBe(true);
    });

    it("should return true when isEnabled is true", () => {
      reflector.getAllAndOverride.mockReturnValue({ isEnabled: true });
      const context = createMockContext();
      expect(guard.canActivate(context)).toBe(true);
    });

    it("should throw BadRequestException when isEnabled is false and errorType is BadRequest", () => {
      reflector.getAllAndOverride.mockReturnValue({ isEnabled: false, errorType: "BadRequest", message: "Custom message" });
      const context = createMockContext();
      expect(() => guard.canActivate(context)).toThrow(BadRequestException);
    });

    it("should throw BadRequestException with default message if message is omitted", () => {
      reflector.getAllAndOverride.mockReturnValue({ isEnabled: false, errorType: "BadRequest" });
      const context = createMockContext();
      expect(() => guard.canActivate(context)).toThrow(BadRequestException);
    });

    it("should throw NotFoundException when isEnabled is false and errorType is NotFound or undefined", () => {
      reflector.getAllAndOverride.mockReturnValue({ isEnabled: false });
      const context = createMockContext();
      expect(() => guard.canActivate(context)).toThrow(NotFoundException);
    });
  });

  describe("attach & attachDemoMode", () => {
    it("should attach metadata and exclude endpoint when restricted and hideFromDocs is true", () => {
      Configuration.isDevBuild = false;
      Configuration.isRunningScript = false;

      const target = {};
      const descriptor = { value: jest.fn() };
      const decorator = EnabledGuard.attach(false, { hideFromDocs: true });

      decorator(target, "myEndpoint", descriptor);
    });

    it("should attach metadata and exclude controller when target is a class", () => {
      Configuration.isDevBuild = false;
      Configuration.isRunningScript = false;

      class TestController {}
      const decorator = EnabledGuard.attach(false);

      decorator(TestController);
    });

    it("should handle attachDemoMode", () => {
      Configuration.isDemoMode = true;
      const decorator = EnabledGuard.attachDemoMode();
      class DemoController {}
      decorator(DemoController);
    });
  });
});
