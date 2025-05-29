import { Database } from "@backend/database/source";
import { User } from "@backend/model/user";
import { SimpleFINProvider } from "@backend/providers/simple-fin/core";
import "reflect-metadata";
import "source-map-support/register";
import { CentralServer } from "./central.server";
import { ConfigurationController } from "./config/controller";
import { Configuration } from "./config/core";
import { Logger } from "./logger";
import { RestAPIServer } from "./web-api/server";

/** The various providers as loaded by our current application */
const providers = {
  simpleFin: new SimpleFINProvider(),
};

/** Main function for kicking off the application */
async function main() {
  // Log what program is starting up
  Logger.success(`Starting ${Configuration.appName} ${Configuration.version} in ${Configuration.isDevBuild ? "development" : "production"} mode`);
  // Initialize config
  new ConfigurationController().load();
  // Initialize database
  // TODO: Database migrations
  await Database.init();
  // Initialize server
  const centralServer = new CentralServer();
  await new RestAPIServer(centralServer.server).initialize();
  Logger.success("Server ready!");
  // TODO: Scheduler
  // await new Scheduler().start();
  // TODO: Cleanup
  const adminUser = (await User.findOne({ where: { admin: true } }))!;
  console.log(`DEV JWT: ${adminUser.JWT}`);
  providers.simpleFin.get();
}

// Execute main so long as this file is not being imported
if (require.main === module) main();
