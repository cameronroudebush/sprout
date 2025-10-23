// /**
//  * This file provides migration handling for what to do when a migration is requested.
//  */

// import "../main"; // Load main so we know what database models we have

// let database: Database;

// /** Sets up the database to generate a migration of */
// async function setup() {
//   Logger.info("Starting sqlite migration");
//   database = new Database();
//   // Initialize required endpoints so we have all db models loaded
//   new RestAPIServer({} as any).initialize();

//   const originalInitialize = database.source!.initialize.bind(database.source);
//   const monkeyPatchedInitialize = async () => {
//     const result = await originalInitialize();
//     await database.setSQLitePRAGMA(false);
//     return result;
//   };
//   database.source.initialize = monkeyPatchedInitialize;

//   return database.source;
// }

// export default setup();

// TODO
