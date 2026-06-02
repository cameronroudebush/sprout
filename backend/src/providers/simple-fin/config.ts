import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";
import { BaseProviderConfig } from "@backend/providers/base/config";

/** The configuration for the SimpleFIN provider */
export class SimpleFINConfig extends BaseProviderConfig {
  @ConfigurationMetadata.assign({ comment: "If this provider is enabled to execute syncs in the background", restrictedValues: [true, false] })
  override enabled = true;

  @ConfigurationMetadata.assign({ comment: "How often to update this provider.", externalControlDisabled: true })
  override syncFrequency: string = "0 8 * * *";

  @ConfigurationMetadata.assign({ comment: "How many API calls we allow per day, per user, for this provider." })
  rateLimit: number = 24;
}
