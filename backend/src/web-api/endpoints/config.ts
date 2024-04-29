import { Configuration } from "@backend/config/core";
import { Configuration as CommonConfiguration, RestEndpoints } from "@common";
import { FirstTimeSetup } from "../../setup";
import { RestMetadata } from "../metadata";

export class ConfigAPI {
  /** Returns the app configuration for the frontend to be able to reference */
  @RestMetadata.register(new RestMetadata(RestEndpoints.conf.get, "GET"))
  async getAppConfig() {
    return CommonConfiguration.fromPlain({
      isFirstTimeSetup: await FirstTimeSetup.isFirstTimeSetup(),
      version: Configuration.version,
    });
  }
}
