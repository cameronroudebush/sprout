import { ConfigurationService } from "@backend/config/config.service";
import { Configuration } from "@backend/config/core";
import { SproutLogger } from "@backend/core/logger";
import { Logger } from "@nestjs/common";
import { startCase } from "lodash-es";
import pkg from "../package.json" with { type: "json" };
const { name } = pkg;

// Determine if we're running the script before we try to initialize the config
Configuration.isRunningScript = Configuration.isDevBuild && process.argv[2] != null;

/**
 * Executes runner scripts and exits before starting the HTTP server.
 */
export async function checkScript() {
  const scriptName = process.argv[2];
  try {
    switch (scriptName) {
      case "generate.api-spec": {
        const { generateOpenApiSpec } = await import("./scripts/generate.api-spec.js");
        await generateOpenApiSpec(process.argv[3]);
        process.exit(0);
      }
      case "generate.migration": {
        const migrationName = process.argv[3];
        if (!migrationName) {
          throw new Error("Migration name is required. Example: npm run migrate -- MY_MIGRATION_NAME");
        }
        const { generateMigration } = await import("./scripts/generate.migration.js");
        await generateMigration(migrationName);
        process.exit(0);
      }
      default:
        throw new Error(`Failed to locate matching script to execute: ${scriptName}`);
    }
  } catch (e) {
    Logger.error(e);
    process.exit(1);
  }
}

/** Main execution wrapper */
export async function main() {
  const projName = startCase(name);
  new ConfigurationService(new SproutLogger(projName, { logLevels: ["verbose"] })).load();

  // Check if we have scripts to run
  if (Configuration.isRunningScript) await checkScript();

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
