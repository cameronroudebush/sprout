import { Configuration } from "@backend/config/core";
import { Configuration as APIConfig, UnsecureAppConfiguration } from "@backend/model/api/config";
import { RestEndpoints } from "@backend/model/api/endpoint";
import { Schedule } from "@backend/model/schedule";
import { RestMetadata } from "../metadata";
import { SetupAPI } from "./setup";

export class ConfigAPI {
  /** Returns the app configuration for the frontend to be able to reference */
  @RestMetadata.register(new RestMetadata(RestEndpoints.conf.get, "GET"))
  async getAppConfig() {
    return APIConfig.fromPlain({ lastSchedulerRun: (await Schedule.find({ order: { time: "DESC" } }))[0] });
  }

  /** Returns the app configuration for the frontend to be able to reference */
  @RestMetadata.register(new RestMetadata(RestEndpoints.conf.getUnsecure, "GET", false))
  async getUnsecureAppConfig() {
    return UnsecureAppConfiguration.fromPlain({
      firstTimeSetupPosition: await SetupAPI.firstTimeSetupDetermination(),
      version: Configuration.version,
    });
  }
}
