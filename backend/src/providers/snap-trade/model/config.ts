import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";
import { BaseProviderConfig } from "@backend/providers/base/config";

/** The configuration for the SnapTrade provider */
export class SnapTradeConfig extends BaseProviderConfig {
  @ConfigurationMetadata.assign({ comment: "If this provider is enabled to execute syncs in the background", restrictedValues: [true, false] })
  override enabled = true;

  @ConfigurationMetadata.assign({ comment: "The Client ID provided by SnapTrade for API access." })
  clientId: string = "";

  @ConfigurationMetadata.assign({ comment: "The Consumer Key provided by SnapTrade used for HMAC-SHA256 request signing." })
  consumerKey: string = "";

  @ConfigurationMetadata.assign({ comment: "How many API calls we allow per day, per user, for this provider." })
  rateLimit: number = 24;
}
