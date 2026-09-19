import { ConfigurationService } from "@backend/config/config.service";
import { Configuration } from "@backend/config/core";
import { SproutLogger } from "@backend/core/logger";
import { Logger } from "@nestjs/common";
import { startCase } from "lodash-es";
import pkg from "../package.json" with { type: "json" };
const { name } = pkg;

/**
 * This allows us to run this app and then execute a specific script
 *  instead. This helps configure the app like it would normally be but then allows us to execute specific functionality.
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
      default:
        throw new Error("Failed to locate matching script to execute");
    }
  } catch (e) {
    Logger.error(e);
    process.exit(1);
  }
}

/** This function is the main execution of the app. It sets up the configuration then configures the Nest server */
async function main() {
  const projName = startCase(name);
  new ConfigurationService(new SproutLogger(projName, { logLevels: ["verbose"] })).load();
  Configuration.isRunningScript = Configuration.isDevBuild && process.argv[2] != null;

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
if (import.meta.main) main();
