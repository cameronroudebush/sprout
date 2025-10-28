import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";
import { registeredEntities } from "@backend/database/decorators";
import { glob } from "glob";
import path from "path";
import { DataSourceOptions } from "typeorm";

/** SQLite specific configuration options */
export class SQLiteConfig {
  @ConfigurationMetadata.assign({ comment: "Database file name" })
  database: string = "sprout.sqlite";
}

/** Backup configuration for the database */
export class BackupConfig {
  @ConfigurationMetadata.assign({ comment: "If backups should occur" })
  enabled: boolean = true;

  @ConfigurationMetadata.assign({ comment: "How many backups we should keep" })
  count: number = 30;

  @ConfigurationMetadata.assign({ comment: "When to backup the database. Default is once a day at 4am." })
  time: string = "0 4 * * *";

  @ConfigurationMetadata.assign({ comment: "Where to place the backup files." })
  directory: string = path.resolve("backups", "database");
}

/** Database specific backend configuration */
export class DatabaseConfig {
  @ConfigurationMetadata.assign({ comment: "Configuration for performing database backups automatically" })
  backup = new BackupConfig();

  @ConfigurationMetadata.assign({ comment: "The type of database we want to use", restrictedValues: ["sqlite"] })
  type: "sqlite" = "sqlite";

  @ConfigurationMetadata.assign({ comment: "SQLite specific configuration options" })
  sqlite = new SQLiteConfig();

  /** Returns the database configuration used to initialize the data source */
  get dbConfig() {
    const migrationsDirectory = path.resolve(path.join(__dirname, "database", "migration", this.type));
    const migrationFiles = glob.sync("/**/*.*[!.map]", { root: path.join(migrationsDirectory) });
    return {
      ...this.sqlite,
      type: this.type,
      entities: registeredEntities,
      migrationsRun: false,
      migrations: migrationFiles,
      synchronize: false,
    } as DataSourceOptions;
  }
}
