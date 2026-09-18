import { setupTests } from "@backend/test/helpers";
setupTests();

jest.mock("@backend/scripts/generate.api-spec", () => ({
  generateOpenApiSpec: jest.fn().mockResolvedValue(undefined),
}));

jest.mock("@backend/server", () => ({
  startupServer: jest.fn().mockResolvedValue(undefined),
}));

jest.mock("@backend/config/config.service", () => {
  return {
    ConfigurationService: jest.fn().mockImplementation(() => ({
      load: jest.fn(),
    })),
  };
});

import { Configuration } from "@backend/config/core";
import { checkScript, main } from "@backend/main";

describe("main.ts", () => {
  let originalArgv: string[];
  let exitSpy: jest.SpyInstance;
  let originalDevBuild: boolean;

  beforeEach(() => {
    jest.clearAllMocks();
    originalArgv = [...process.argv];
    originalDevBuild = Configuration.isDevBuild;
    exitSpy = jest.spyOn(process, "exit").mockImplementation((() => undefined) as never);
  });

  afterEach(() => {
    process.argv = originalArgv;
    Configuration.isDevBuild = originalDevBuild;
    exitSpy.mockRestore();
  });

  describe("checkScript", () => {
    it("should execute generate.api-spec script and exit 0", async () => {
      process.argv = ["node", "main.js", "generate.api-spec", "out.json"];
      const generateApiSpec = require("@backend/scripts/generate.api-spec");

      await checkScript();

      expect(generateApiSpec.generateOpenApiSpec).toHaveBeenCalledWith("out.json");
      expect(exitSpy).toHaveBeenCalledWith(0);
    });

    it("should throw error and exit 1 if script name is unknown", async () => {
      process.argv = ["node", "main.js", "invalid-script"];

      await checkScript();

      expect(exitSpy).toHaveBeenCalledWith(1);
    });
  });

  describe("main", () => {
    it("should start server in production mode (non-dev build)", async () => {
      Configuration.isDevBuild = false;
      process.argv = ["node", "main.js"];
      const serverModule = require("@backend/server");

      await main();

      expect(serverModule.startupServer).toHaveBeenCalled();
    });

    it("should generate openapi spec and start server in dev build mode when no script provided", async () => {
      Configuration.isDevBuild = true;
      process.argv = ["node", "main.js"];
      const generateApiSpec = require("@backend/scripts/generate.api-spec");
      const serverModule = require("@backend/server");

      await main();

      expect(generateApiSpec.generateOpenApiSpec).toHaveBeenCalledWith("../docs/assets/openapi-spec.json");
      expect(serverModule.startupServer).toHaveBeenCalled();
    });

    it("should execute checkScript when running script in dev build mode", async () => {
      Configuration.isDevBuild = true;
      process.argv = ["node", "main.js", "generate.api-spec", "out.json"];
      const generateApiSpec = require("@backend/scripts/generate.api-spec");

      await main();

      expect(generateApiSpec.generateOpenApiSpec).toHaveBeenCalledWith("out.json");
      expect(exitSpy).toHaveBeenCalledWith(0);
    });
  });
});
