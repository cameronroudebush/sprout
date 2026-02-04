import { AuthenticationConfig } from "@backend/auth/model/authentication.config";
import { ChatConfig } from "@backend/chat/model/chat.config.model";
import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";
import { RateLimitConfig } from "@backend/config/model/rate.limit.config";
import { JobsConfig } from "@backend/jobs/model/jobs.config";
import { NotificationConfig } from "@backend/notification/model/notification.config";
import { LOG_LEVELS, LogLevel } from "@nestjs/common";

/** Options that should be provided to the core of the web server */
export class ServerConfig {
  @ConfigurationMetadata.assign({ comment: "The port to accept backend requests on." })
  port: number = 8001;

  @ConfigurationMetadata.assign({ comment: "The base path that the API is hosted on.", externalControlDisabled: true })
  basePath: string = "/api";

  @ConfigurationMetadata.assign({ comment: "The log levels we want to render content for.", restrictedValues: LOG_LEVELS })
  logLevels: LogLevel[] = ["log", "error", "warn"];

  @ConfigurationMetadata.assign({ comment: "Configuration for rate limiting of the endpoints." })
  rateLimit = new RateLimitConfig();

  @ConfigurationMetadata.assign({ comment: "Configuration for the various jobs." })
  jobs = new JobsConfig();

  @ConfigurationMetadata.assign({ comment: "Configuration for how we want to use authentication for this app." })
  auth = new AuthenticationConfig();

  @ConfigurationMetadata.assign({ comment: "Configuration for automated notifications." })
  notification = new NotificationConfig();

  @ConfigurationMetadata.assign({ comment: "Configuration for LLM prompting." })
  prompt = new ChatConfig();
}
