import { ExecutionContext, ForbiddenException } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { StrategyGuard } from "./strategy.guard";

(global as any).__mockConfigState = {
  server: {
    auth: {
      type: "local",
    },
  },
  isRunningScript: false,
};

// Main trackers for factory invocation arguments
const mockSetMetadataSpy = vi.fn().mockImplementation(() => vi.fn());
const mockUseGuardsSpy = vi.fn().mockImplementation(() => vi.fn());
const mockApiExcludeEndpointSpy = vi.fn().mockImplementation(() => vi.fn());
const mockApiExcludeControllerSpy = vi.fn().mockImplementation(() => vi.fn());

vi.mock("@backend/config/core", () => ({
  get Configuration() {
    return (global as any).__mockConfigState;
  },
}));

vi.mock("@nestjs/swagger", () => ({
  ApiExcludeEndpoint: () => mockApiExcludeEndpointSpy(),
  ApiExcludeController: () => mockApiExcludeControllerSpy(),
}));

vi.mock("@nestjs/common", async (importOriginal) => {
  const actual = await importOriginal<typeof import("@nestjs/common")>();
  return {
    ...actual,
    UseGuards: (...args: any[]) => mockUseGuardsSpy(...args),
    SetMetadata: (...args: any[]) => mockSetMetadataSpy(...args),
  };
});

describe("StrategyGuard", () => {
  let guard: StrategyGuard;
  let reflector: Mocked<Reflector>;
  let mockContext: Mocked<ExecutionContext>;

  beforeEach(() => {
    vi.clearAllMocks();
    reflector = { getAllAndOverride: vi.fn() } as any;
    mockContext = { getHandler: vi.fn(), getClass: vi.fn() } as any;
    guard = new StrategyGuard(reflector);
  });

  describe("canActivate", () => {
    it("should allow activation if no metadata strategy method is defined", () => {
      reflector.getAllAndOverride.mockReturnValue(undefined);
      expect(guard.canActivate(mockContext)).toBe(true);
    });

    it("should allow activation if required strategy matches the configured active strategy", () => {
      (global as any).__mockConfigState.server.auth.type = "local";
      reflector.getAllAndOverride.mockReturnValue("local");
      expect(guard.canActivate(mockContext)).toBe(true);
    });

    it("should throw ForbiddenException if required strategy does not match the active strategy", () => {
      (global as any).__mockConfigState.server.auth.type = "local";
      reflector.getAllAndOverride.mockReturnValue("oidc");
      expect(() => guard.canActivate(mockContext)).toThrow(ForbiddenException);
    });
  });

  describe("attach decorator", () => {
    const mockTarget = function () {};
    const mockPropertyKey = "testMethod";
    const mockDescriptor = {};

    it("should apply metadata and UseGuards but NOT exclude anything if the strategy matches", () => {
      (global as any).__mockConfigState.server.auth.type = "local";
      (global as any).__mockConfigState.isRunningScript = false;

      const decorator = StrategyGuard.attach("local");
      decorator(mockTarget, mockPropertyKey, mockDescriptor);

      expect(mockSetMetadataSpy).toHaveBeenCalledWith(StrategyGuard.METADATA_KEY, "local");
      expect(mockUseGuardsSpy).toHaveBeenCalledWith(StrategyGuard);
      expect(mockApiExcludeEndpointSpy).not.toHaveBeenCalled();
      expect(mockApiExcludeControllerSpy).not.toHaveBeenCalled();
    });

    it("should exclude endpoint from Swagger if configured strategy differs at method level", () => {
      (global as any).__mockConfigState.server.auth.type = "oidc";
      (global as any).__mockConfigState.isRunningScript = false;

      const decorator = StrategyGuard.attach("local");
      decorator(mockTarget, mockPropertyKey, mockDescriptor);

      expect(mockApiExcludeEndpointSpy).toHaveBeenCalled();
    });

    it("should exclude controller from Swagger if configured strategy differs at class level", () => {
      (global as any).__mockConfigState.server.auth.type = "oidc";
      (global as any).__mockConfigState.isRunningScript = false;

      const decorator = StrategyGuard.attach("local");
      decorator(mockTarget, undefined as any, undefined as any);

      expect(mockApiExcludeControllerSpy).toHaveBeenCalled();
    });

    it("should skip Swagger exclusions entirely if isRunningScript is true", () => {
      (global as any).__mockConfigState.server.auth.type = "oidc";
      (global as any).__mockConfigState.isRunningScript = true;

      const decorator = StrategyGuard.attach("local");
      decorator(mockTarget, mockPropertyKey, mockDescriptor);

      expect(mockApiExcludeEndpointSpy).not.toHaveBeenCalled();
      expect(mockApiExcludeControllerSpy).not.toHaveBeenCalled();
    });
  });
});
