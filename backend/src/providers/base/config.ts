/** A class that defines base requirements to every provider config */
export abstract class BaseProviderConfig {
  /** If this provider is enabled to execute in the background or be able to add new accounts. */
  abstract enabled: boolean;
  /** A cron of how often we want to update this provider */
  abstract syncFrequency: string;
}
