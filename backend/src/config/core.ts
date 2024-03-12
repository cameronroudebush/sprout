import { ConfigurationMetadata } from "./configuration.metadata";
import { PlaidConfiguration } from "./plaid.config";

/**
 * The Configuration class that the entire backend utilizes for it's config capabilities. You can call any Configuration value statically and these will be loaded from the file on startup.
 */
export class Configuration {
  /** Plaid specific configuration for financial loading */
  @ConfigurationMetadata.assign({})
  static plaid = new PlaidConfiguration();
}
