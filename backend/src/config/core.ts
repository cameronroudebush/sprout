import { name, version } from "../../package.json";
import { ConfigurationMetadata } from "./configuration.metadata";
import { PlaidConfiguration } from "./plaid.config";

/**
 * The Configuration class that the entire backend utilizes for it's config capabilities. You can call any Configuration value statically and these will be loaded from the file on startup.
 */
export class Configuration {
  @ConfigurationMetadata.assign({ comment: "Plaid specific configuration for financial loading" })
  static plaid = new PlaidConfiguration();

  static get version() {
    return version;
  }

  static get appName() {
    return name;
  }
}
