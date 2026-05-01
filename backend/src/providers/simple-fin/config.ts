import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";
import { BaseProviderConfig } from "@backend/providers/base/config";

/** The configuration for the SimpleFIN provider */
export class SimpleFINConfig extends BaseProviderConfig {
  @ConfigurationMetadata.assign({ comment: "How often to update this provider." })
  override syncFrequency: string = "0 8,20 * * *";

  @ConfigurationMetadata.assign({ comment: "How many API calls we allow per day, per user, for this provider." })
  rateLimit: number = 24;
}
