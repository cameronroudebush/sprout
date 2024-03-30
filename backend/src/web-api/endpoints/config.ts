import { Configuration } from "@backend/config/core";
import { Configuration as CommonConfiguration, RestEndpoints } from "@common";
import { RestMetadata } from "../metadata";

export class ConfigAPI {
  @RestMetadata.register(new RestMetadata(RestEndpoints.conf.get, "GET"))
  async login() {
    return CommonConfiguration.fromPlain({
      version: Configuration.version,
    });
  }
}
