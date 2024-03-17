import { User } from "@common";
import chalk from "chalk";
import "reflect-metadata";
import { ConfigurationController } from "./config/controller";
import { Configuration } from "./config/core";
import { PlaidCore } from "./finance-api/plaid/core";
import { Logger } from "./logger";

/** Main function for kicking off the application */
async function main() {
  // Log what program is starting up
  Logger.log(`Starting ${Configuration.appName} v${Configuration.version}`, chalk.green, false);
  // Initialize config
  new ConfigurationController().load();
  console.log(await new PlaidCore().getTransactions(new User()));
}

// Execute main so long as this file is not being imported
if (require.main === module) main();
