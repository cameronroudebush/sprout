/** Class that provides configuration information to Configuration object properties */
export class ConfigurationMetadata {
  /** If this value should be hidden from the config file */
  externalControlDisabled = false;
  // /** Values that we must */
  // restrictedValues: Array<any> | undefined;

  /** A comment that can be written before the configuration value */
  comment: string | undefined;

  /** Metadata key for this information */
  static readonly METADATA_KEY = "config:metadata";

  /** Assigns the given metadata to the property this value decorates. */
  static assign(value: Partial<ConfigurationMetadata>) {
    return function (target: any, key: string) {
      Reflect.defineMetadata(ConfigurationMetadata.METADATA_KEY, value, target, key);
    };
  }
}
