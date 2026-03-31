import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";
import { BaseProviderConfig } from "@backend/providers/base/config";

/** The configuration for the Zillow provider */
export class ZillowConfig extends BaseProviderConfig {
  @ConfigurationMetadata.assign({ comment: "How often to update this provider. Default is every Sunday at 4am" })
  override syncFrequency: string = "0 6 * * 0";

  @ConfigurationMetadata.assign({ comment: "How many API calls we allow per day, per user, for this provider." })
  rateLimit: number = 4;
}
