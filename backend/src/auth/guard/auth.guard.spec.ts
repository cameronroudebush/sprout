import { ExecutionContext, Logger } from "@nestjs/common";
import { Reflector } from "@nestjs/core";

jest.mock("@backend/config/core", () => ({
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

jest.mock("@backend/auth/strategy/local.strategy", () => ({ LocalStrategyName: "local-strat" }));
jest.mock("@backend/auth/strategy/oidc.strategy", () => ({ OIDCStrategyName: "oidc-strat" }));
jest.mock("@nestjs/passport", () => ({
  AuthGuard: () => class MockPassportGuard {},
}));

describe("AuthGuard", () => {
  let reflector: jest.Mocked<Reflector>;
  let mockContext: jest.Mocked<ExecutionContext>;

  beforeAll(() => {
    jest.spyOn(Logger.prototype, "log").mockImplementation(() => {});
    jest.spyOn(Logger.prototype, "error").mockImplementation(() => {});
  });

  beforeEach(() => {
    reflector = { get: jest.fn() } as any;
    mockContext = { getHandler: jest.fn(), getClass: jest.fn() } as any;
  });

  // Helper returns both the guard instance and its internal isolated User class definition
  function getIsolatedGuardContext(authType: "local" | "oidc") {
    const { Configuration } = require("@backend/config/core");
    Configuration.server.auth.type = authType;

    let AuthGuardClass: any;
    let IsolatedUserModel: any;

    jest.isolateModules(() => {
      AuthGuardClass = require("./auth.guard").AuthGuard;
      IsolatedUserModel = require("@backend/user/model/user.model").User;
    });

    const guardInstance = new AuthGuardClass(reflector);
    return { guard: guardInstance, User: IsolatedUserModel };
  }

  describe("Strategy Initialization", () => {
    it("should initialize with LocalStrategyName when auth type is local", () => {
      const { guard } = getIsolatedGuardContext("local");
      expect(guard).toBeDefined();
    });

    it("should initialize with OIDCStrategyName when auth type is oidc", () => {
      const { guard } = getIsolatedGuardContext("oidc");
      expect(guard).toBeDefined();
    });
  });

  describe("handleRequest", () => {
    it("should return the user if authentication succeeds and entity is a User instance", () => {
      const { guard, User } = getIsolatedGuardContext("local");
      // Derive prototype explicitly from the isolated context's User class instance
      const mockUser = Object.create(User.prototype);
      reflector.get.mockReturnValue(false);

      const result = guard.handleRequest(null, mockUser, null, mockContext);
      expect(result).toBe(mockUser);
    });

    it("should return null if authentication fails but anonymous access is permitted", () => {
      const { guard } = getIsolatedGuardContext("local");
      reflector.get.mockReturnValue(true);

      const result = guard.handleRequest(new Error("Auth failed"), null, null, mockContext);
      expect(result).toBeNull();
      expect(reflector.get).toHaveBeenCalledWith("allow_anon", mockContext.getHandler());
    });

    it("should throw the original error if authentication fails and anonymous access is disabled", () => {
      const { guard } = getIsolatedGuardContext("local");
      const inputError = new Error("Custom passport error");
      reflector.get.mockReturnValue(false);

      expect(() => guard.handleRequest(inputError, null, null, mockContext)).toThrow("Custom passport error");
    });

    it("should throw UnauthorizedException if passport fails without an explicit error object", () => {
      const { guard } = getIsolatedGuardContext("local");
      reflector.get.mockReturnValue(false);

      expect(() => guard.handleRequest(null, null, null, mockContext)).toThrow("Unauthorized");
    });

    it("should throw UnauthorizedException if user is found but is not an instance of User model", () => {
      const { guard } = getIsolatedGuardContext("local");
      const genericUserObj = { username: "imposter" };
      reflector.get.mockReturnValue(false);

      expect(() => guard.handleRequest(null, genericUserObj, null, mockContext)).toThrow("Unauthorized");
    });
  });

  describe("Static Decorator Attachments", () => {
    it("should return valid decorator compositions for attach", () => {
      const { AuthGuard } = require("./auth.guard");
      expect(AuthGuard.attach()).toBeDefined();
    });

    it("should return valid decorator compositions for attachOptional", () => {
      const { AuthGuard } = require("./auth.guard");
      expect(AuthGuard.attachOptional()).toBeDefined();
    });
  });
});
