import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";
import { BaseProviderConfig } from "@backend/providers/base/config";

/** The configuration for the SimpleFIN provider */
export class SimpleFINConfig extends BaseProviderConfig {
  @ConfigurationMetadata.assign({ comment: "How often to update this provider. Default is daily at 6am" })
  override syncFrequency: string = "0 6 * * *";

  @ConfigurationMetadata.assign({ comment: "How many days to look back for transactional data." })
  lookBackDays: number = 14;

  @ConfigurationMetadata.assign({ comment: "How many API calls we allow per day, per user, for this provider." })
  rateLimit: number = 24;
}
