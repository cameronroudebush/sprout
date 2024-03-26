import chalk from "chalk";
import "reflect-metadata";
import { CentralServer } from "./central.server";
import { ConfigurationController } from "./config/controller";
import { Configuration } from "./config/core";
import { Logger } from "./logger";
import { RestAPIServer } from "./web-api/server";

/** Main function for kicking off the application */
async function main() {
  // Log what program is starting up
  Logger.log(`Starting ${Configuration.appName} v${Configuration.version}`, chalk.green, false);
  // Initialize config
  new ConfigurationController().load();
  // Initialize server
  const centralServer = new CentralServer();
  await new RestAPIServer(centralServer.server).initialize();
  // console.log(await new PlaidCore().getAccounts(new User()));
  Logger.log("Server ready!");
}

// Execute main so long as this file is not being imported
if (require.main === module) main();
