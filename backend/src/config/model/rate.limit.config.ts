import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";

/** Endpoint rate limiting config for the app */
export class RateLimitConfig {
  @ConfigurationMetadata.assign({ comment: "How long the limit window is." })
  ttl: number = 60000; // 1 minute

  @ConfigurationMetadata.assign({ comment: "How many requests we can have in the limit window." })
  limit: number = 1000;
}
