import { ServerConfig } from "@backend/config/server";
import * as uuid from "uuid";
import { name } from "../../package.json";
import { ConfigurationMetadata } from "./configuration.metadata";
import { PlaidConfiguration } from "./plaid.config";

/**
 * The Configuration class that the entire backend utilizes for it's config capabilities. You can call any Configuration value statically and these will be loaded from the file on startup.
 */
export class Configuration {
  @ConfigurationMetadata.assign({ comment: "Plaid specific configuration for financial loading." })
  static plaid = new PlaidConfiguration();

  @ConfigurationMetadata.assign({ comment: "Core server config options" })
  static server = new ServerConfig();

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
