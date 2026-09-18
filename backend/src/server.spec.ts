import { setupTests } from "@backend/test/helpers";
setupTests();

jest.mock("@backend/core/openapi", () => ({
  setupOpenApiHelp: jest.fn(),
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
    jest.clearAllMocks();

    originalDevBuild = Configuration.isDevBuild;
    originalDemoMode = Configuration.isDemoMode;
    originalAuthType = Configuration.server.auth.type;
    originalBuildDate = process.env["BUILD_DATE"];
    process.env["BUILD_DATE"] = "2026-01-01T00:00:00.000Z";

    mockApp = {
      setGlobalPrefix: jest.fn(),
      useGlobalPipes: jest.fn(),
      use: jest.fn(),
      set: jest.fn(),
      enableCors: jest.fn(),
      get: jest.fn().mockImplementation((key) => {
        if (key && key.name === "ConfigurationService") {
          return { configFileLocation: "/tmp/config.json" };
        }
        if (key && key.name === "DatabaseService") {
          return { init: jest.fn().mockResolvedValue(undefined) };
        }
        if (key && key.name === "DemoDataService") {
          return { populateDemoData: jest.fn().mockResolvedValue(undefined) };
        }
        return {};
      }),
      listen: jest.fn().mockResolvedValue(undefined),
    };

    jest.spyOn(NestFactory, "create").mockResolvedValue(mockApp as any);
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
      validate: jest.fn(),
    } as any;

    await startupServer("SproutTest");

    expect(NestFactory.create).toHaveBeenCalled();
    expect(Configuration.server.auth.oidc.validate).toHaveBeenCalled();
    expect(mockApp.listen).toHaveBeenCalledWith(Configuration.server.port);
  });

  it("should handle error during startup and exit process gracefully", async () => {
    const exitSpy = jest.spyOn(process, "exit").mockImplementation((() => undefined) as never);
    jest.spyOn(NestFactory, "create").mockRejectedValueOnce(new Error("Startup error test"));

    await startupServer("SproutTest");

    expect(exitSpy).toHaveBeenCalledWith(1);
    exitSpy.mockRestore();
  });
});
