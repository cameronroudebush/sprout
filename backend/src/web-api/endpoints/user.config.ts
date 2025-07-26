import { RestEndpoints } from "@backend/model/api/endpoint";
import { RestBody } from "@backend/model/api/rest.request";
import { User } from "@backend/model/user";
import { UserConfig } from "@backend/model/user.config";
import { RestMetadata } from "../metadata";

export class UserConfigAPI {
  /** Returns the user configuration for the current user */
  @RestMetadata.register(new RestMetadata(RestEndpoints.userConfig.get, "GET"))
  async get(_request: RestBody, user: User) {
    return (await User.findOne({ where: { id: user.id } }))?.config;
  }

  /** Accepts updates to the given user configuration */
  @RestMetadata.register(new RestMetadata(RestEndpoints.userConfig.update, "POST"))
  async update(request: RestBody, user: User) {
    const existingConfig = (await UserConfig.findOne({ where: { id: user.config.id } }))!;
    const userConfig = UserConfig.fromPlain(request.payload);
    userConfig.id = existingConfig.id;
    return await userConfig.update();
  }
}
