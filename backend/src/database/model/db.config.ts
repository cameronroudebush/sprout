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

/** Configuration options for Grandfather-Father-Son (GFS) backup retention */
export class GfsBackupConfig {
  @ConfigurationMetadata.assign({ comment: "Number of daily backups (Son) to retain." })
  dailyCount: number = 7;

  @ConfigurationMetadata.assign({ comment: "Number of weekly backups (Father) to retain." })
  weeklyCount: number = 4;

  @ConfigurationMetadata.assign({ comment: "Number of monthly backups (Grandfather) to retain." })
  monthlyCount: number = 12;

  @ConfigurationMetadata.assign({ comment: "Number of quarterly backups to retain." })
  quarterlyCount: number = 4;

  @ConfigurationMetadata.assign({ comment: "Number of yearly backups to retain." })
  yearlyCount: number = 5;
}

/** Backup configuration for the database */
export class BackupConfig {
  @ConfigurationMetadata.assign({ comment: "If backups should occur" })
  enabled: boolean = true;

  @ConfigurationMetadata.assign({ comment: "When to backup the database. Default is once a day at 7:00am.", externalControlDisabled: true })
  time: string = "0 7 * * *";

  @ConfigurationMetadata.assign({ comment: "Where to place the backup files." })
  directory: string = path.resolve("backups", "database");

  @ConfigurationMetadata.assign({ comment: "Grandfather-Father-Son retention configuration." })
  gfs: GfsBackupConfig = new GfsBackupConfig();
}

/** Database specific backend configuration */
export class DatabaseConfig {
  @ConfigurationMetadata.assign({ comment: "Configuration for performing database backups automatically" })
  backup = new BackupConfig();

  @ConfigurationMetadata.assign({ comment: "The type of database we want to use", restrictedValues: ["better-sqlite3"] })
  type: "better-sqlite3" = "better-sqlite3";

  @ConfigurationMetadata.assign({ comment: "SQLite specific configuration options" })
  sqlite = new SQLiteConfig();

  /** Returns if this is an sqlite database type */
  get isSqlite() {
    return this.type === "better-sqlite3";
  }

  /** Returns the database configuration used to initialize the data source */
  get dbConfig() {
    const dbType: "sqlite" = this.type === "better-sqlite3" ? "sqlite" : "sqlite";
    const migrationsDirectory = path.resolve(path.join(__dirname, "database", "migration", dbType));
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
