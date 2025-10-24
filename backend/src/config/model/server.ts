import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";
import { RateLimitConfig } from "@backend/config/model/rate.limit.config";
import { JobsConfig } from "@backend/jobs/model/jobs.config";
import { LOG_LEVELS, LogLevel } from "@nestjs/common";

/** Options that should be provided to the core of the web server */
export class ServerConfig {
  @ConfigurationMetadata.assign({ comment: "The port to accept backend requests on." })
  port: number = 8001;

  @ConfigurationMetadata.assign({ comment: "How long JWT's should stay valid for users." })
  jwtExpirationTime = "30m";

  @ConfigurationMetadata.assign({ comment: "The log levels we want to render content for.", restrictedValues: LOG_LEVELS })
  logLevels: LogLevel[] = ["log", "error", "warn"];

  @ConfigurationMetadata.assign({ comment: "Configuration for rate limiting of the endpoints." })
  rateLimit = new RateLimitConfig();

  @ConfigurationMetadata.assign({ comment: "Configuration for the various jobs." })
  jobs = new JobsConfig();
}
