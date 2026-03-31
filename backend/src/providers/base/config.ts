/** A class that defines base requirements to every provider config */
export abstract class BaseProviderConfig {
  /** A cron of how often we want to update this provider */
  abstract syncFrequency: string;
}
