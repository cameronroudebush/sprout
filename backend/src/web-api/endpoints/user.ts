import { RestEndpoints, RestRequest, User } from "@common";
import { RestMetadata } from "../metadata";

export class UserRestAPI {
  @RestMetadata.register(new RestMetadata(RestEndpoints.User.login, "POST"))
  async login(request: RestRequest<User>) {
    console.log(request);
  }
}
