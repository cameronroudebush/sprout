import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";

/** The configuration for the Zillow provider */
export class ZillowConfig {
  @ConfigurationMetadata.assign({ comment: "How many API calls we allow per day, per user, for this provider." })
  rateLimit: number = 100;
}
