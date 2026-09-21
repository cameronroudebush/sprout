import { setupTests } from "@backend/test/helpers";
setupTests();

vi.mock("@backend/scripts/generate.api-spec.js", () => ({
  generateOpenApiSpec: vi.fn().mockResolvedValue(undefined),
}));

vi.mock("@backend/server.js", () => ({
  startupServer: vi.fn().mockResolvedValue(undefined),
}));

vi.mock("@backend/config/config.service", () => {
  return {
    ConfigurationService: vi.fn().mockImplementation(function () {
      return {
        load: vi.fn(),
      };
    }),
  };
});

import { Configuration } from "@backend/config/core";
import { checkScript, main } from "@backend/main";
import * as generateApiSpec from "@backend/scripts/generate.api-spec.js";
import * as serverModule from "@backend/server.js";
import { MockInstance } from "vitest";

describe("main.ts", () => {
  let originalArgv: string[];
  let exitSpy: MockInstance;
  let originalDevBuild: boolean;
  let originalIsRunningScript: boolean;

  beforeEach(() => {
    vi.clearAllMocks();
    originalArgv = [...process.argv];
    originalDevBuild = Configuration.isDevBuild;
    originalIsRunningScript = Configuration.isRunningScript;
    exitSpy = vi.spyOn(process, "exit").mockImplementation((() => undefined) as never);
  });

  afterEach(() => {
    process.argv = originalArgv;
    Configuration.isDevBuild = originalDevBuild;
    Configuration.isRunningScript = originalIsRunningScript;
    exitSpy.mockRestore();
  });

  describe("checkScript", () => {
    const originalArgv = process.argv;

    afterEach(() => {
      process.argv = originalArgv;
    });
    it("should execute generate.api-spec script and exit 0", async () => {
      process.argv = ["node", "main.js", "generate.api-spec", "out.json"];

      await checkScript();

      expect(generateApiSpec.generateOpenApiSpec).toHaveBeenCalledWith("out.json");
      expect(exitSpy).toHaveBeenCalledWith(0);
    }, 15000);

    it("should throw error and exit 1 if script name is unknown", async () => {
      process.argv = ["node", "main.js", "invalid-script"];

      await checkScript();

      expect(exitSpy).toHaveBeenCalledWith(1);
    });
  });

  describe("main", () => {
    it("should start server in production mode (non-dev build)", async () => {
      Configuration.isDevBuild = false;
      Configuration.isRunningScript = false;
      process.argv = ["node", "main.js"];

      await main();

      expect(serverModule.startupServer).toHaveBeenCalled();
    });

    it("should generate openapi spec and start server in dev build mode when no script provided", async () => {
      Configuration.isDevBuild = true;
      Configuration.isRunningScript = false;
      process.argv = ["node", "main.js"];

      await main();

      expect(generateApiSpec.generateOpenApiSpec).toHaveBeenCalledWith("../docs/assets/openapi-spec.json");
      expect(serverModule.startupServer).toHaveBeenCalled();
    });

    it("should execute checkScript when running script in dev build mode", async () => {
      Configuration.isDevBuild = true;
      process.argv = ["node", "main.js", "generate.api-spec", "out.json"];
      Configuration.isRunningScript = Configuration.isDevBuild && process.argv[2] != null;

      await main();

      expect(generateApiSpec.generateOpenApiSpec).toHaveBeenCalledWith("out.json");
      expect(exitSpy).toHaveBeenCalledWith(0);
    });
  });
});
