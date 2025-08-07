import { Configuration } from "@backend/config/core";
import { LogConfig, Logger } from "@backend/logger";
import { DataSource } from "typeorm";

/** This class contains the actual database initialization */
export class InternalDatabase {
  /** The connection data source */
  source: DataSource;

  /** Logger options to help this database connection make more sense in the logger */
  logOptions: LogConfig = { header: `[${Configuration.database.type}]` };

  constructor() {
    this.source = new DataSource(Configuration.database.dbConfig);
  }

  /** Initializes the database based on the backend configuration */
  async init() {
    Logger.info(`Attempting SQLite connection at: ${this.source.options.database}`, this.logOptions);
    await this.source.initialize();
    Logger.info(`Connection successful`, this.logOptions);
    if (!(await this.databaseExists())) {
      Logger.info("Initializing a new database", this.logOptions);
    }
    if (await this.databaseExists()) {
      Logger.info("Database already initialized. Checking migrations...");
      const executedMigrations = await this.executeMigrations();
      if (executedMigrations.length > 0) Logger.info(`Executed ${executedMigrations.length} migration(s)`);
      else Logger.success(`No migrations to execute!`);
    }
    // Confirm we have no more migrations
    await this.checkForMigrations();
    Logger.success("Database initialized! Ready for queries.", this.logOptions);
    return this;
  }

  /** Returns if the current database exists or not in our installed database */
  private async databaseExists(databaseName = Configuration.database.dbConfig.database, source = this.source) {
    this.validateSource(source);
    if (Configuration.database.type === "sqlite") return (await source.query("SELECT name FROM sqlite_master WHERE type='table'")).length >= 1;
    else return (await source.query("SHOW DATABASES LIKE ?", [databaseName])).length >= 1;
  }

  /** Validates that the given source exists or throws an error if not */
  validateSource(source = this.source): asserts source is DataSource {
    if (source == null) throw new Error("Database not initialized. Did you forget to call `init`?");
  }

  // /** Using the current data source, checks if any migrations are required and throws an error if they are. */
  private async checkForMigrations(source = this.source) {
    Logger.info("Checking for migrations...", this.logOptions);
    this.validateSource(source);
    const sqlInMemory = await source.driver.createSchemaBuilder().log();
    const migrationsRequired = sqlInMemory.upQueries.length !== 0;
    if (migrationsRequired)
      if (Configuration.isDevBuild) throw new Error(`Database migrations are required. Did you forget to run the migration generation command?`);
      else throw new Error(`Database migrations are required. Refusing to continue.`);
    else Logger.info("No migration required!", this.logOptions);
  }

  //   /** Executes any available migrations */
  private async executeMigrations(source = this.source) {
    this.validateSource(source);
    await this.setSQLitePRAGMA(false);
    const resolvedMigrations = await source.runMigrations({ transaction: "all" });
    await this.setSQLitePRAGMA(true);
    return resolvedMigrations;
  }

  /**
   * This function sets some given PRAGMA settings that the pain that is SQLite will require when we run migration files
   *
   * Capabilities modified:
   * `foreign_keys`: This is important because migrations recreate tables utilizing temp tables which causes a mess with foreign keys that don't really need to change.
   * `legacy_alter_table`: As tables are altered for migrations, it adjusts sqlite to not update foreign key reference table names. So when we rename the temp tables
   *    it doesn't break any references. Leaving this enabled would cause reverting migrations to always think data changed.
   *
   * See this info: https://github.com/typeorm/typeorm/issues/2584#issuecomment-408013561
   */
  async setSQLitePRAGMA(enabled: boolean, source = this.source) {
    if (Configuration.database.type !== "sqlite") return; // Don't do anything if not SQLite
    this.validateSource(source);
    if (enabled) {
      await source.query("PRAGMA foreign_keys=ON;");
      await source.query("PRAGMA legacy_alter_table=OFF;");
    } else {
      await source.query("PRAGMA foreign_keys=OFF;");
      await source.query("PRAGMA legacy_alter_table=ON;");
    }
  }
}

/** The database instance we should use across the app */
export const Database = new InternalDatabase();
