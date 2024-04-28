import { ConfigurationMetadata } from "@backend/config/configuration.metadata";
import { registeredEntities } from "@backend/database/decorators";
import { DataSourceOptions } from "typeorm";

/** SQLite specific configuration options */
export class SQLiteConfig {
  @ConfigurationMetadata.assign({ comment: "Database file name" })
  database: string = "sprout.sqlite";
}

/** Database specific backend configuration */
export class DatabaseConfig {
  @ConfigurationMetadata.assign({ comment: "The type of database we want to use", restrictedValues: ["sqlite"] })
  type: "sqlite" = "sqlite";

  @ConfigurationMetadata.assign({ comment: "SQLite specific configuration options" })
  sqlite = new SQLiteConfig();

  /** Returns the database configuration used to initialize the data source */
  get dbConfig() {
    return { ...this.sqlite, type: this.type, entities: registeredEntities } as DataSourceOptions;
  }
}
