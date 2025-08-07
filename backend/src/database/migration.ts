/**
 * This file provides migration handling for what to do when a migration is requested.
 */

import { Database } from "@backend/database/source";
import { Logger } from "@backend/logger";
import "../main"; // Load main so we know what database models we have

let database: Database;

/** Sets up the database to generate a migration of */
async function setup() {
  Logger.info("Starting sqlite migration");
  database = new Database();

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
