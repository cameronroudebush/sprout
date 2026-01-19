import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";

/** The configuration for the SimpleFIN provider */
export class SimpleFINConfig {
  @ConfigurationMetadata.assign({ comment: "How many days to look back for transactional data." })
  lookBackDays: number = 7;

  @ConfigurationMetadata.assign({ comment: "How many API calls we allow per day, per user, for this provider." })
  rateLimit: number = 24;
}
