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
    // Initialize database
    const database = await new Database().init();
    DatabaseBase.database = database;
    // Initialize background jobs
    await new JobProcessor().start();
    // Initialize server
    const centralServer = new CentralServer();
    await new RestAPIServer(centralServer).initialize();
    Logger.success("Server ready!");
    // Schedule our provider to run
    await Providers.initializeProviders();
    const provider = Providers.getCurrentProvider();
    await provider.sync.start();
  } catch (e) {
    Logger.error(e as Error);
    process.exit(1);
  }
}

// Execute main so long as this file is not being imported
if (require.main === module) main();
