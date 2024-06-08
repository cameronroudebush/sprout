import { Configuration } from "@backend/config/core";
import { Configuration as CommonConfiguration, RestEndpoints, UnsecureAppConfiguration as UnsecureCommonConfiguration } from "@common";
import { RestMetadata } from "../metadata";
import { SetupAPI } from "./setup";

export class ConfigAPI {
  /** Returns the app configuration for the frontend to be able to reference */
  @RestMetadata.register(new RestMetadata(RestEndpoints.conf.get, "GET"))
  async getAppConfig() {
    return CommonConfiguration.fromPlain({});
  }

  /** Returns the app configuration for the frontend to be able to reference */
  @RestMetadata.register(new RestMetadata(RestEndpoints.conf.getUnsecure, "GET", false))
  async getUnsecureAppConfig() {
    return UnsecureCommonConfiguration.fromPlain({
      firstTimeSetupPosition: await SetupAPI.firstTimeSetupDetermination(),
      version: Configuration.version,
    });
  }
}
