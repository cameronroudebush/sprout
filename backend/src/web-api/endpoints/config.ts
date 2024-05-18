import { Configuration } from "@backend/config/core";
import { Configuration as CommonConfiguration, RestEndpoints, UnsecureAppConfiguration as UnsecureCommonConfiguration } from "@common";
import { FirstTimeSetup } from "../../setup";
import { RestMetadata } from "../metadata";

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
      isFirstTimeSetup: await FirstTimeSetup.isFirstTimeSetup(),
      version: Configuration.version,
    });
  }
}
