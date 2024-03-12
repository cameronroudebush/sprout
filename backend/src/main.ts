import chalk from "chalk";
import "reflect-metadata";
import { name, version } from "../package.json";
import { ConfigurationController } from "./config/controller";
import { Logger } from "./logger";

/** Main function for kicking off the application */
async function main() {
  // Log what program is starting up
  Logger.log(`Starting ${name} v${version}`, chalk.green, false);
  // Initial config
  new ConfigurationController();
}

// Execute main so long as this file is not being imported
if (require.main === module) main();
