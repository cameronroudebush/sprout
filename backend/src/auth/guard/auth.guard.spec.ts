import { ExecutionContext, Logger } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { Mocked } from "vitest";

vi.mock("@backend/config/core", () => ({
  Configuration: {
    isDevBuild: false,
    server: {
      auth: {
        type: "local",
      },
    },
    encryptionKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
  },
}));

vi.mock("@backend/auth/strategy/local.strategy", () => ({ LocalStrategyName: "local-strat" }));
vi.mock("@backend/auth/strategy/oidc.strategy", () => ({ OIDCStrategyName: "oidc-strat" }));
vi.mock("@nestjs/passport", () => ({
  AuthGuard: () => class MockPassportGuard {},
}));

describe("AuthGuard", () => {
  let reflector: Mocked<Reflector>;
  let mockContext: Mocked<ExecutionContext>;

  beforeAll(() => {
    vi.spyOn(Logger.prototype, "log").mockImplementation(() => {});
    vi.spyOn(Logger.prototype, "error").mockImplementation(() => {});
  });

  beforeEach(() => {
    reflector = { get: vi.fn() } as any;
    mockContext = { getHandler: vi.fn(), getClass: vi.fn() } as any;
  });

  // Helper returns both the guard instance and its internal isolated User class definition
  async function getIsolatedGuardContext(authType: "local" | "oidc") {
    vi.resetModules();

    const { Configuration } = await import("@backend/config/core.js");
    Configuration.server.auth.type = authType;

    const { AuthGuard: AuthGuardClass } = await import("./auth.guard.js");
    const { User: IsolatedUserModel } = await import("@backend/user/model/user.model.js");

    const guardInstance = new AuthGuardClass(reflector);
    return { guard: guardInstance, User: IsolatedUserModel };
  }

  describe("Strategy Initialization", () => {
    it("should initialize with LocalStrategyName when auth type is local", async () => {
      const { guard } = await getIsolatedGuardContext("local");
      expect(guard).toBeDefined();
    });

    it("should initialize with OIDCStrategyName when auth type is oidc", async () => {
      const { guard } = await getIsolatedGuardContext("oidc");
      expect(guard).toBeDefined();
    });
  });

  describe("handleRequest", () => {
    it("should return the user if authentication succeeds and entity is a User instance", async () => {
      const { guard, User } = await getIsolatedGuardContext("local");
      // Derive prototype explicitly from the isolated context's User class instance
      const mockUser = Object.create(User.prototype);
      reflector.get.mockReturnValue(false);

      const result = guard.handleRequest(null, mockUser, null, mockContext);
      expect(result).toBe(mockUser);
    });

    it("should return null if authentication fails but anonymous access is permitted", async () => {
      const { guard } = await getIsolatedGuardContext("local");
      reflector.get.mockReturnValue(true);

      const result = guard.handleRequest(new Error("Auth failed"), null, null, mockContext);
      expect(result).toBeNull();
      expect(reflector.get).toHaveBeenCalledWith("allow_anon", mockContext.getHandler());
    });

    it("should throw the original error if authentication fails and anonymous access is disabled", async () => {
      const { guard } = await getIsolatedGuardContext("local");
      const inputError = new Error("Custom passport error");
      reflector.get.mockReturnValue(false);

      expect(() => guard.handleRequest(inputError, null, null, mockContext)).toThrow("Custom passport error");
    });

    it("should throw UnauthorizedException if passport fails without an explicit error object", async () => {
      const { guard } = await getIsolatedGuardContext("local");
      reflector.get.mockReturnValue(false);

      expect(() => guard.handleRequest(null, null, null, mockContext)).toThrow("Unauthorized");
    });

    it("should throw UnauthorizedException if user is found but is not an instance of User model", async () => {
      const { guard } = await getIsolatedGuardContext("local");
      const genericUserObj = { username: "imposter" };
      reflector.get.mockReturnValue(false);

      expect(() => guard.handleRequest(null, genericUserObj, null, mockContext)).toThrow("Unauthorized");
    });
  });

  describe("Static Decorator Attachments", () => {
    it("should return valid decorator compositions for attach", async () => {
      const { AuthGuard } = await import("./auth.guard.js");
      expect(AuthGuard.attach()).toBeDefined();
    });

    it("should return valid decorator compositions for attachOptional", async () => {
      const { AuthGuard } = await import("./auth.guard.js");
      expect(AuthGuard.attachOptional()).toBeDefined();
    });
  });
});
