import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";
import { BaseProviderConfig } from "@backend/providers/base/config";
import { PlaidEnvironments } from "plaid";

/** The configuration for the Plaid provider */
export class PlaidConfig extends BaseProviderConfig {
  @ConfigurationMetadata.assign({ comment: "How often to update this provider. Default is to run every 6 hours, starting at 6am." })
  override syncFrequency: string = "0 */6 * * *";

  @ConfigurationMetadata.assign({ comment: "How many API calls we allow per day, per user, for this provider." })
  rateLimit: number = 100;

  @ConfigurationMetadata.assign({
    comment: "The mode that we are searching for data on for our clientId and secret.",
    restrictedValues: [PlaidEnvironments["sandbox"], PlaidEnvironments["production"]],
  })
  environment = PlaidEnvironments["production"]!;

  @ConfigurationMetadata.assign({ comment: "The client Id for your plaid implementation." })
  clientId!: string;

  @ConfigurationMetadata.assign({ comment: "The secret for authenticating with your plaid instance. DO NOT SHARE THIS." })
  secret!: string;
}
