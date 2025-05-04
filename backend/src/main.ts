import { Database } from "@backend/database/source";
import { API_CORE } from "@backend/financeAPI/core";
import { PlaidCore } from "@backend/financeAPI/plaid/core";
import { User } from "@backend/model/user";
import "reflect-metadata";
import "source-map-support/register";
import { CentralServer } from "./central.server";
import { ConfigurationController } from "./config/controller";
import { Configuration } from "./config/core";
import { Logger } from "./logger";
import { Scheduler } from "./scheduler";
import { RestAPIServer } from "./web-api/server";

/** Main function for kicking off the application */
async function main() {
  // Log what program is starting up
  Logger.success(`Starting ${Configuration.appName} ${Configuration.version} in ${Configuration.isDevBuild ? "development" : "production"} mode`);
  // Initialize config
  new ConfigurationController().load();
  // Initialize database
  await Database.init();
  // Initialize server
  const centralServer = new CentralServer();
  await new RestAPIServer(centralServer.server).initialize();
  // Initialize the API core
  API_CORE.App = new PlaidCore();
  Logger.success("Server ready!");
  await new Scheduler().start();
  // TODO: Cleanup
  const adminUser = (await User.findOne({ where: { admin: true } }))!;
  console.log(`DEV JWT: ${adminUser.JWT}`);
}

// Execute main so long as this file is not being imported
if (require.main === module) main();
