import { DatabaseConfig } from "@backend/config/db.config";
import { ServerConfig } from "@backend/config/server";
import { TransactionConfig } from "@backend/config/transaction";
import * as uuid from "uuid";
import { name } from "../../package.json";
import { ConfigurationMetadata } from "./configuration.metadata";
import { ProvidersConfig } from "./providers";

/**
 * The Configuration class that the entire backend utilizes for it's config capabilities. You can
 *  call any Configuration value statically and these will be loaded from the file on startup.
 */
export class Configuration {
  @ConfigurationMetadata.assign({ comment: "Configuration for the various providers" })
  static providers = new ProvidersConfig();

  @ConfigurationMetadata.assign({ comment: "Core server config options" })
  static server = new ServerConfig();

  @ConfigurationMetadata.assign({ comment: "Database specific optioons" })
  static database = new DatabaseConfig();

  @ConfigurationMetadata.assign({ comment: "Settings specific to transactions" })
  static transaction = new TransactionConfig();

  /** This variable contains the application version of this build. This will be replaced by {@link build.ts}. */
  static version = "APP-VERSION";

  /** A secret key that can be used to create JWT's and other relevant info for this app. **This will be regenerated during every restart!** */
  static secretKey = uuid.v4();

  static get appName() {
    return name;
  }

  /** Boolean that states if this is a development build or not. This will be replaced by {@link build.ts}. */
  static isDevBuild = false;
}
