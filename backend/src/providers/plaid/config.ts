import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";
import { BaseProviderConfig } from "@backend/providers/base/config";
import { ProviderCredentialsMode } from "@backend/providers/base/model/provider.credential.type";
import { PlaidEnvironments } from "plaid";

/** The configuration for the Plaid provider */
export class PlaidConfig extends BaseProviderConfig {
  @ConfigurationMetadata.assign({ comment: "If this provider is enabled to execute syncs in the background", restrictedValues: [true, false] })
  override enabled = true;

  @ConfigurationMetadata.assign({ comment: "How many API calls we allow per day, per user, for this provider." })
  rateLimit: number = 1000;

  @ConfigurationMetadata.assign({
    comment: "The credential source to use for Plaid API requests.",
    restrictedValues: [PlaidEnvironments["sandbox"], PlaidEnvironments["production"]],
  })
  environment = PlaidEnvironments["production"]!;

  @ConfigurationMetadata.assign({
    comment: "Which Plaid credentials to use: system-wide credentials or credentials configured by each user.",
    restrictedValues: Object.values(ProviderCredentialsMode),
  })
  credentialsMode = ProviderCredentialsMode.SYSTEM;

  @ConfigurationMetadata.assign({ comment: "The client Id for your plaid implementation." })
  clientId!: string;

  @ConfigurationMetadata.assign({ comment: "The secret for authenticating with your plaid instance. DO NOT SHARE THIS." })
  secret!: string;
}
