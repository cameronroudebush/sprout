import { ConfigurationService } from "@backend/config/config.service";
import { Configuration } from "@backend/config/core";
import { SproutLogger } from "@backend/core/logger";
import { Logger } from "@nestjs/common";
import { startCase } from "lodash-es";
import pkg from "../package.json" with { type: "json" };
const { name } = pkg;

// Determine if we're running the script before we try to initialize the config
Configuration.isRunningScript = Configuration.isDevBuild && process.argv[2] != null;

/** Determines whether a command can run before config validation or needs loaded app config. */
type ScriptPhase = "pre-setup" | "post-setup";

const SCRIPTS: Record<ScriptPhase, Map<string, () => Promise<void>>> = {
  // Setup-independent commands, such as generating the required encryption key.
  "pre-setup": new Map([
    // Prints a fresh encryption key without loading or validating app config.
    [
      "generate-key",
      async () => {
        const { EncryptionTransformer } = await import("./core/decorator/encryption.decorator.js");
        const key = EncryptionTransformer.generateRandomEncryptionKey();
        const logger = new SproutLogger("Generate Key", { colors: false });
        logger.log("Sprout encryption key generated successfully!");
        logger.log("Copy this key into sprout_encryptionKey in your Compose file:");
        logger.success(key);
        logger.log("Keep this key private and back it up safely. Thanks for using Sprout :)");
      },
    ],
  ]),
  // Developer commands that run after configuration is loaded and validated.
  "post-setup": new Map([
    // Exports the OpenAPI document to the requested output path.
    [
      "generate.api-spec",
      async () => {
        const { generateOpenApiSpec } = await import("./scripts/generate.api-spec.js");
        await generateOpenApiSpec(process.argv[3]);
      },
    ],
    // Creates a database migration after validating its required name.
    [
      "generate.migration",
      async () => {
        const migrationName = process.argv[3];
        if (!migrationName) {
          throw new Error("Migration name is required. Example: npm run migrate -- MY_MIGRATION_NAME");
        }
        const { generateMigration } = await import("./scripts/generate.migration.js");
        await generateMigration(migrationName);
      },
    ],
  ]),
};

/** Runs the command registered for the requested startup phase. */
export async function checkScript(phase: ScriptPhase) {
  const scriptName = process.argv[2] ?? "";
  const script = SCRIPTS[phase].get(scriptName);
  if (!script) {
    if (phase === "pre-setup") return false;
    Logger.error(new Error(`Failed to locate matching script to execute: ${scriptName}`));
    process.exit(1);
    return true;
  }

  try {
    await script();
    if (phase === "post-setup") process.exit(0);
    return true;
  } catch (e) {
    Logger.error(e);
    process.exit(1);
    return true;
  }
}

/** Main execution wrapper */
export async function main() {
  // Handle commands that must run before config loading and validation.
  if (await checkScript("pre-setup")) return;

  const projName = startCase(name);
  new ConfigurationService(new SproutLogger(projName, { logLevels: ["verbose"] })).load();

  // Run config-dependent commands after loading and validating application config.
  if (Configuration.isRunningScript) {
    await checkScript("post-setup");
    return;
  }

  // Auto generate open api spec on startup in-case of changes for development environment
  if (Configuration.isDevBuild) {
    Configuration.isRunningScript = true; // Set as startup script so the endpoints aren't hidden
    const { generateOpenApiSpec } = await import("./scripts/generate.api-spec.js");
    await generateOpenApiSpec("../docs/assets/openapi-spec.json");
    Configuration.isRunningScript = false;
  }

  // Execute the server startup.
  const { startupServer } = await import("./server.js");
  await startupServer(name);
}

// Execute main so long as this file is not being imported
/* v8 ignore next -- import.meta.main is true only when Node executes this module as its entrypoint. */
if (import.meta.main) main();
