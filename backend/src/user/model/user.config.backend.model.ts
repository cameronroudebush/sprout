import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";

/** Contains user configuration options */
export class UserConfig {
  @ConfigurationMetadata.assign({ comment: "When to check for user devices that we haven't seen in awhile." })
  deviceCheckTime: string = "0 */6 * * *";

  @ConfigurationMetadata.assign({ comment: "How many days it takes for a device to be considered stuck." })
  days: number = 7;
}
