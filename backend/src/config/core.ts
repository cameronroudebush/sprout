import { ServerConfig } from "@backend/config/model/server";
import { DatabaseConfig } from "@backend/database/model/db.config";
import { TransactionConfig } from "@backend/transaction/model/transaction.config";
import * as uuid from "uuid";
import { name } from "../../package.json";
import { ProvidersConfig } from "../providers/model/provider.config";
import { ConfigurationMetadata } from "./model/configuration.metadata";

/**
 * The Configuration class that the entire backend utilizes for it's config capabilities. You can
 *  call any Configuration value statically and these will be loaded from the file on startup.
 */
export class Configuration {
  @ConfigurationMetadata.assign({ comment: "Configuration for the various providers" })
  static providers = new ProvidersConfig();

  @ConfigurationMetadata.assign({ comment: "Core server config options" })
  static server = new ServerConfig();

  @ConfigurationMetadata.assign({ comment: "Database specific options" })
  static database = new DatabaseConfig();

  @ConfigurationMetadata.assign({ comment: "Settings specific to transactions" })
  static transaction = new TransactionConfig();

  /** This variable contains the application version of this build. This is replaced by webpack. */
  static version = process.env["APP_VERSION"]!;

  /** A secret key that can be used to create JWT's and other relevant info for this app. **This will be regenerated during every restart!** */
  static secretKey = process.env["SECRET_KEY"]! ?? uuid.v4();

  static get appName() {
    return name;
  }

  /** Boolean that states if this is a development build or not. This is replaced by webpack. */
  static isDevBuild = process.env["IS_DEV_BUILD"]!;
}
