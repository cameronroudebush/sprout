import { JobsConfig } from "@backend/config/jobs";
import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";
import { LogLevel } from "@nestjs/common";

/** Options that should be provided to the core of the web server */
export class ServerConfig {
  @ConfigurationMetadata.assign({ comment: "The port to accept backend requests on." })
  port: number = 8001;

  @ConfigurationMetadata.assign({ comment: "How long JWT's should stay valid for users." })
  jwtExpirationTime = "30m";

  @ConfigurationMetadata.assign({ comment: "The log levels we want to render content for." })
  logLevels: LogLevel[] = ["log", "error", "warn"];

  @ConfigurationMetadata.assign({ comment: "Configuration for the various jobs" })
  jobs = new JobsConfig();
}
