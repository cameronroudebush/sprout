import { AuthService } from "@backend/auth/auth.service";
import { LocalStrategy } from "@backend/auth/strategy/local.strategy";
import { OIDCStrategy } from "@backend/auth/strategy/oidc.strategy";
import { Logger } from "@nestjs/common";

const mockConfigState = {
  server: {
    auth: {
      type: "local",
    },
  },
};

jest.mock("@backend/config/core", () => ({
  get Configuration() {
    return mockConfigState;
  },
}));

jest.mock("@backend/auth/auth.service", () => ({ AuthService: class {} }));
jest.mock("@backend/auth/strategy/local.strategy", () => ({ LocalStrategy: class {} }));
jest.mock("@backend/auth/strategy/oidc.strategy", () => ({ OIDCStrategy: class {} }));
jest.mock("@backend/auth/auth.controller", () => ({ AuthController: class {} }));
jest.mock("@backend/auth/auth.oidc.controller", () => ({ OIDCController: class {} }));
jest.mock("@backend/user/user.module", () => ({ UserModule: class {} }));
jest.mock("@nestjs/axios", () => ({ HttpModule: class {} }));
jest.mock("@nestjs/passport", () => ({ PassportModule: class {} }));

describe("AuthModule", () => {
  async function compileIsolatedModule() {
    let AuthModule: any;

    jest.isolateModules(() => {
      AuthModule = require("./auth.module").AuthModule;
    });

    const { Test } = require("@nestjs/testing");
    return Test.createTestingModule({
      imports: [AuthModule],
    }).compile();
  }

  beforeAll(() => {
    // Suppress log outputs during unit tests
    jest.spyOn(Logger.prototype, "log").mockImplementation(() => {});
    jest.spyOn(Logger.prototype, "error").mockImplementation(() => {});
    jest.spyOn(Logger.prototype, "warn").mockImplementation(() => {});
    jest.spyOn(Logger.prototype, "debug").mockImplementation(() => {});
  });

  it("should compile successfully and include LocalStrategy when config type is local", async () => {
    mockConfigState.server.auth.type = "local";

    const module = await compileIsolatedModule();

    expect(module).toBeDefined();
    expect(module.get(AuthService)).toBeDefined();
    expect(module.get(LocalStrategy)).toBeDefined();
    expect(() => module.get(OIDCStrategy)).toThrow();
  });

  it("should compile successfully and include OIDCStrategy when config type is oidc", async () => {
    mockConfigState.server.auth.type = "oidc";

    const module = await compileIsolatedModule();

    expect(module).toBeDefined();
    expect(module.get(AuthService)).toBeDefined();
    expect(module.get(OIDCStrategy)).toBeDefined();
    expect(() => module.get(LocalStrategy)).toThrow();
  });
});
