import { Configuration } from "@backend/config/core";
import { Logger } from "@nestjs/common";
import { startCase } from "lodash";
import "source-map-support/register";
import { name } from "../package.json";
import { ConfigurationService } from "./config/config.service";
import { SproutLogger } from "./core/logger";

/**
 * This allows us to run this app and then execute a specific script
 *  instead. This helps configure the app like it would normally be but then allows us to execute specific functionality.
 */
export async function checkScript() {
  const scriptName = process.argv[2];
  try {
    switch (scriptName) {
      case "generate.api-spec":
        await require("./scripts/generate.api-spec").generateOpenApiSpec(process.argv[3]);
        process.exit(0);
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
    await require("./scripts/generate.api-spec").generateOpenApiSpec("../docs/assets/openapi-spec.json");
    Configuration.isRunningScript = false;
  }

  // Execute the server startup.
  await require("./server").startupServer();
}

// Execute main so long as this file is not being imported
if (require.main === module) main();
