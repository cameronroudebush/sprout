import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";

class DeviceCheck {
  @ConfigurationMetadata.assign({
    comment: "If we should check for devices that haven't been seen in awhile and clean them up.",
    restrictedValues: [true, false],
  })
  enabled = true;

  @ConfigurationMetadata.assign({ comment: "When to check for user devices that we haven't seen in awhile. Should be cron expression." })
  time: string = "0 */6 * * *";

  @ConfigurationMetadata.assign({ comment: "How many days it takes for a device to be considered stuck." })
  days: number = 7;
}

/** Contains user configuration options */
export class UserConfig {
  @ConfigurationMetadata.assign({ comment: "Configuration options related to user devices." })
  deviceCheck = new DeviceCheck();
}
