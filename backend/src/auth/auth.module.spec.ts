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

vi.mock("@backend/config/core", () => ({
  get Configuration() {
    return mockConfigState;
  },
}));

vi.mock("@backend/auth/auth.service", () => ({ AuthService: class {} }));
vi.mock("@backend/auth/strategy/local.strategy", () => ({ LocalStrategy: class {} }));
vi.mock("@backend/auth/strategy/oidc.strategy", () => ({ OIDCStrategy: class {} }));
vi.mock("@backend/auth/auth.controller", () => ({ AuthController: class {} }));
vi.mock("@backend/auth/auth.oidc.controller", () => ({ OIDCController: class {} }));
vi.mock("@backend/user/user.module", () => ({ UserModule: class {} }));
vi.mock("@nestjs/axios", () => ({ HttpModule: class {} }));
vi.mock("@nestjs/passport", () => ({ PassportModule: class {} }));

describe("AuthModule", () => {
  async function compileIsolatedModule() {
    vi.resetModules();
    const { AuthModule } = await import("./auth.module.js");
    const { Test } = await import("@nestjs/testing");
    return Test.createTestingModule({
      imports: [AuthModule],
    }).compile();
  }

  beforeAll(() => {
    // Suppress log outputs during unit tests
    vi.spyOn(Logger.prototype, "log").mockImplementation(() => {});
    vi.spyOn(Logger.prototype, "error").mockImplementation(() => {});
    vi.spyOn(Logger.prototype, "warn").mockImplementation(() => {});
    vi.spyOn(Logger.prototype, "debug").mockImplementation(() => {});
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
