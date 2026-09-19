import { setupTests } from "@backend/test/helpers";
setupTests();

vi.mock("@backend/core/openapi", () => ({
  setupOpenApiHelp: vi.fn(),
}));

import { Configuration } from "@backend/config/core";
import { startupServer } from "@backend/server";
import { NestFactory } from "@nestjs/core";

describe("server.ts", () => {
  let mockApp: any;
  let originalDevBuild: boolean;
  let originalDemoMode: boolean;
  let originalAuthType: string;
  let originalBuildDate: string | undefined;

  beforeEach(() => {
    vi.clearAllMocks();

    originalDevBuild = Configuration.isDevBuild;
    originalDemoMode = Configuration.isDemoMode;
    originalAuthType = Configuration.server.auth.type;
    originalBuildDate = process.env["BUILD_DATE"];
    process.env["BUILD_DATE"] = "2026-01-01T00:00:00.000Z";

    mockApp = {
      setGlobalPrefix: vi.fn(),
      useGlobalPipes: vi.fn(),
      use: vi.fn(),
      set: vi.fn(),
      enableCors: vi.fn(),
      get: vi.fn().mockImplementation((key) => {
        if (key && key.name === "ConfigurationService") {
          return { configFileLocation: "/tmp/config.json" };
        }
        if (key && key.name === "DatabaseService") {
          return { init: vi.fn().mockResolvedValue(undefined) };
        }
        if (key && key.name === "DemoDataService") {
          return { populateDemoData: vi.fn().mockResolvedValue(undefined) };
        }
        return {};
      }),
      listen: vi.fn().mockResolvedValue(undefined),
    };

    vi.spyOn(NestFactory, "create").mockResolvedValue(mockApp as any);
  });

  afterEach(() => {
    Configuration.isDevBuild = originalDevBuild;
    Configuration.isDemoMode = originalDemoMode;
    Configuration.server.auth.type = originalAuthType as any;
    if (originalBuildDate !== undefined) {
      process.env["BUILD_DATE"] = originalBuildDate;
    } else {
      delete process.env["BUILD_DATE"];
    }
  });

  it("should initialize and start Nest application in development mode", async () => {
    Configuration.isDevBuild = true;
    Configuration.isDemoMode = false;
    Configuration.server.auth.type = "local";

    await startupServer("SproutTest");

    expect(NestFactory.create).toHaveBeenCalled();
    expect(mockApp.setGlobalPrefix).toHaveBeenCalledWith(Configuration.server.basePath);
    expect(mockApp.useGlobalPipes).toHaveBeenCalled();
    expect(mockApp.enableCors).toHaveBeenCalled();
    expect(mockApp.listen).toHaveBeenCalledWith(Configuration.server.port);
  });

  it("should initialize and start Nest application in production mode with demo and OIDC enabled", async () => {
    Configuration.isDevBuild = false;
    Configuration.isDemoMode = true;
    Configuration.server.auth.type = "oidc";
    Configuration.server.auth.oidc = {
      validate: vi.fn(),
    } as any;

    await startupServer("SproutTest");

    expect(NestFactory.create).toHaveBeenCalled();
    expect(Configuration.server.auth.oidc.validate).toHaveBeenCalled();
    expect(mockApp.listen).toHaveBeenCalledWith(Configuration.server.port);
  });

  it("should handle error during startup and exit process gracefully", async () => {
    const exitSpy = vi.spyOn(process, "exit").mockImplementation((() => undefined) as never);
    vi.spyOn(NestFactory, "create").mockRejectedValueOnce(new Error("Startup error test"));

    await startupServer("SproutTest");

    expect(exitSpy).toHaveBeenCalledWith(1);
    exitSpy.mockRestore();
  });
});
