import { Database } from "@backend/database/source";
import { JobProcessor } from "@backend/jobs/jobs";
import { DatabaseBase } from "@backend/model/database.base";
import "reflect-metadata";
import "source-map-support/register";
import { CentralServer } from "./central.server";
import { ConfigurationController } from "./config/controller";
import { Configuration } from "./config/core";
import { Logger } from "./logger";
import { Providers } from "./providers";
import { RestAPIServer } from "./web-api/server";

/** Main function for kicking off the application */
async function main() {
  try {
    // Log what program is starting up
    Logger.success(`Starting ${Configuration.appName} ${Configuration.version} in ${Configuration.isDevBuild ? "development" : "production"} mode`);
    // Initialize config
    new ConfigurationController().load();
    // Initialize server
    const centralServer = new CentralServer();
    const apiServer = await new RestAPIServer(centralServer).initialize();
    // Initialize database
    const database = await new Database().init();
    DatabaseBase.database = database;
    // Init our providers
    await Providers.initializeProviders();
    // Initialize background jobs
    await JobProcessor.start();
    // Start listening for requests
    apiServer.start();
    Logger.success("Server ready!");
  } catch (e) {
    Logger.error(e as Error);
    process.exit(1);
  }
}

// Execute main so long as this file is not being imported
if (require.main === module) main();
