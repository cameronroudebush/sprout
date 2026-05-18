/** A class that defines base requirements to every provider config */
export abstract class BaseProviderConfig {
  /** If this provider is even enabled to execute in the background. */
  abstract bgSyncEnabled: boolean;
  /** A cron of how often we want to update this provider */
  abstract syncFrequency: string;
}
