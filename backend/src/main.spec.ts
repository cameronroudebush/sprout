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
import { checkScript } from "@backend/main";

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
});
