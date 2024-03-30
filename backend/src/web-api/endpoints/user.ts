import { User } from "@backend/model/user";
import { RestBody, RestEndpoints, UserLoginRequest, UserLoginResponse } from "@common";
import { RestMetadata } from "../metadata";

export class UserAPI {
  @RestMetadata.register(new RestMetadata(RestEndpoints.user.login, "POST", false))
  async login(request: RestBody) {
    const userRequest = UserLoginRequest.fromPlain(request.payload);
    const user = User.fromPlain({ id: 1, username: userRequest.username });
    // throw new Error("Login Failed");
    // TODO actual authentication
    return UserLoginResponse.fromPlain({ user: user, jwt: user.JWT });
  }

  @RestMetadata.register(new RestMetadata(RestEndpoints.user.loginJWT, "POST", false))
  async loginWithJWT(request: RestBody) {
    const userRequest = UserLoginRequest.fromPlain(request.payload);
    const user = User.fromPlain({ id: 1, username: userRequest.username });
    // TODO actual authentication
    return UserLoginResponse.fromPlain({ user: user, jwt: user.JWT });
  }
}
