/**
 * While this file is placed in the scripts directory, it must be ran manually
 *  through typeorm so typeorm can turn it into the proper file.
 */

import { AppModule } from "@backend/app.module";
import { SproutLogger } from "@backend/core/logger";
import { DatabaseService } from "@backend/database/database.service";
import { Logger } from "@nestjs/common";
import { NestFactory } from "@nestjs/core";

let database: DatabaseService;

/** Sets up the database to generate a migration of and monkey patches the initialization to handle some requirements. */
async function setup() {
  // Create a "silent" app instance
  const app = await NestFactory.create(AppModule, {
    logger: new SproutLogger("Database Migration Service"),
  });
  database = app.get(DatabaseService);

  Logger.log("Starting sqlite migration");

  const originalInitialize = database.source!.initialize.bind(database.source);
  const monkeyPatchedInitialize = async () => {
    const result = await originalInitialize();
    await database.setSQLitePRAGMA(false);
    return result;
  };
  database.source.initialize = monkeyPatchedInitialize;

  return database.source;
}

export default setup();
