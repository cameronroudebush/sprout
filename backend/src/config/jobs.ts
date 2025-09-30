import { ConfigurationMetadata } from "@backend/config/configuration.metadata";

/** Generic configuration across the jobs */
export class JobsConfig {
  @ConfigurationMetadata.assign({ comment: "How many minutes to wait to re-try failed jobs automatically." })
  autoRetryTime: number = 60;
}
