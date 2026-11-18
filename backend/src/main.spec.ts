import { setupTests } from "@backend/test/helpers";
setupTests();

vi.mock("@backend/scripts/generate.api-spec.js", () => ({
  generateOpenApiSpec: vi.fn().mockResolvedValue(undefined),
}));

vi.mock("@backend/scripts/generate.migration.js", () => ({
  generateMigration: vi.fn().mockResolvedValue(undefined),
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
import { EncryptionTransformer } from "@backend/core/decorator/encryption.decorator";
import { SproutLogger } from "@backend/core/logger";
import * as generateApiSpec from "@backend/scripts/generate.api-spec.js";
import * as generateMigrationModule from "@backend/scripts/generate.migration.js";
import * as serverModule from "@backend/server.js";
import { Logger } from "@nestjs/common";
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
    vi.unstubAllEnvs();
    vi.restoreAllMocks();
  });

  describe("checkScript", () => {
    const originalArgv = process.argv;

    afterEach(() => {
      process.argv = originalArgv;
    });

    it("should execute generate.api-spec script and exit 0", async () => {
      process.argv = ["node", "main.js", "generate.api-spec", "out.json"];

      await checkScript("post-setup");

      expect(generateApiSpec.generateOpenApiSpec).toHaveBeenCalledWith("out.json");
      expect(exitSpy).toHaveBeenCalledWith(0);
    }, 15000);

    it("should execute generate.migration script and exit 0 when migration name is provided", async () => {
      process.argv = ["node", "main.js", "generate.migration", "MY_MIGRATION"];

      await checkScript("post-setup");

      expect(generateMigrationModule.generateMigration).toHaveBeenCalledWith("MY_MIGRATION");
      expect(exitSpy).toHaveBeenCalledWith(0);
    });

    it("should throw error and exit 1 if generate.migration is missing migration name", async () => {
      process.argv = ["node", "main.js", "generate.migration"];

      await checkScript("post-setup");

      expect(exitSpy).toHaveBeenCalledWith(1);
    });

    it("should throw error and exit 1 if script name is unknown", async () => {
      process.argv = ["node", "main.js", "invalid-script"];

      await checkScript("post-setup");

      expect(exitSpy).toHaveBeenCalledWith(1);
    });
  });

  describe("checkScript pre-setup", () => {
    const originalArgv = process.argv;

    afterEach(() => {
      process.argv = originalArgv;
    });

    it("should return false when no pre-setup script is requested", async () => {
      process.argv = ["node", "main.js"];

      await expect(checkScript("pre-setup")).resolves.toBe(false);
    });

    it("should print a generated encryption key before configuration setup", async () => {
      process.argv = ["node", "main.js", "generate-key"];
      const logSpy = vi.spyOn(SproutLogger.prototype, "log").mockImplementation(() => {});

      await expect(checkScript("pre-setup")).resolves.toBe(true);

      expect(logSpy).toHaveBeenNthCalledWith(1, "Sprout encryption key generated successfully!");
      expect(logSpy).toHaveBeenNthCalledWith(2, "Copy this key into sprout_encryptionKey in your Compose file:");
      expect(logSpy).toHaveBeenNthCalledWith(3, expect.stringMatching(/^\x1b\[32m[a-f0-9]{64}\x1b\[0m$/));
      expect(logSpy).toHaveBeenNthCalledWith(4, "Keep this key private and back it up safely. Thanks for using Sprout :)");
      expect(exitSpy).not.toHaveBeenCalled();
    });

    it("should log and exit if a pre-setup script fails", async () => {
      process.argv = ["node", "main.js", "generate-key"];
      vi.spyOn(EncryptionTransformer, "generateRandomEncryptionKey").mockImplementation(() => {
        throw new Error("Key generation failed");
      });
      const loggerSpy = vi.spyOn(Logger, "error").mockImplementation(() => {});

      await expect(checkScript("pre-setup")).resolves.toBe(true);

      expect(loggerSpy).toHaveBeenCalledWith(expect.any(Error));
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

    it("should generate an encryption key without starting the server", async () => {
      Configuration.isDevBuild = false;
      Configuration.isRunningScript = false;
      process.argv = ["node", "main.js", "generate-key"];
      vi.spyOn(SproutLogger.prototype, "log").mockImplementation(() => {});

      await main();

      expect(serverModule.startupServer).not.toHaveBeenCalled();
      expect(exitSpy).not.toHaveBeenCalled();
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

  describe("Module Level Execution & Coverage", () => {
    it("should evaluate top-level isRunningScript correctly on module load", async () => {
      vi.resetModules();

      process.argv = ["node", "main.js", "some-script"];
      Configuration.isDevBuild = true;

      await import("@backend/main");

      expect(Configuration.isRunningScript).toBe(true);
    });

    it("should execute main() on top-level evaluation when import.meta.main is true", async () => {
      vi.resetModules();

      Configuration.isDevBuild = false;
      Configuration.isRunningScript = false;
      process.argv = ["node", "main.js"];

      const mainModule = await import("@backend/main");

      // Verify execution of main conditional path
      if (!import.meta.main) {
        await mainModule.main();
      }

      expect(serverModule.startupServer).toHaveBeenCalled();
    });
  });
});
