import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";

/** A class that defines base requirements to every provider config */
export abstract class BaseProviderConfig {
  /** If this provider is enabled to execute in the background or be able to add new accounts. */
  abstract enabled: boolean;
  /** A cron of how often we want to update this provider */
  @ConfigurationMetadata.assign({ comment: "How often to update this provider.", externalControlDisabled: true })
  readonly syncFrequency: string = "0 6,18 * * *"; // Runs daily at 6:00 AM and 6:00 PM
}
