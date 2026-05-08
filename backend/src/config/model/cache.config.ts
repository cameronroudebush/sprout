import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";

/** Configuration for redis specifically */
class RedisConfig {
  @ConfigurationMetadata.assign({ comment: "The hostname to connect to redis at." })
  host!: string;

  @ConfigurationMetadata.assign({ comment: "The port to connect to redis at." })
  port!: string;

  @ConfigurationMetadata.assign({ comment: "The optional password for connecting to redis." })
  password?: string;

  /** Validates the config is correct. Throws an error if not */
  validate() {
    if (!this.host) throw new Error("The host must be set for cache type of redis.");
    if (!this.port) throw new Error("The port must be set for cache type of redis.");
  }
}

/** Configuration for the cache service */
export class CacheConfig {
  @ConfigurationMetadata.assign({ comment: "What type of cache we should use.", restrictedValues: ["local", "redis"] })
  type: "local" | "redis" = "local";

  @ConfigurationMetadata.assign({ comment: "If type is redis, utilizes this configuration for connecting to redis." })
  redis = new RedisConfig();
}
