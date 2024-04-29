import { User } from "@backend/model/user";
import { RestBody, RestEndpoints, UserLoginRequest, UserLoginResponse } from "@common";
import { EndpointError } from "../error";
import { RestMetadata } from "../metadata";

// Fake User
const user = User.fromPlain({ id: 1, firstName: "John", lastName: "Demo" });

export class UserAPI {
  @RestMetadata.register(new RestMetadata(RestEndpoints.user.login, "POST", false))
  async login(request: RestBody) {
    const userRequest = UserLoginRequest.fromPlain(request.payload);
    user.username = userRequest.username;
    // throw new Error("Login Failed");
    // TODO actual authentication
    return UserLoginResponse.fromPlain({ user: user, jwt: user.JWT });
  }

  @RestMetadata.register(new RestMetadata(RestEndpoints.user.loginJWT, "POST", false))
  async loginWithJWT(request: RestBody) {
    const userRequest = UserLoginRequest.fromPlain(request.payload);
    user.username = userRequest.username;
    try {
      User.verifyJWT(userRequest.jwt!);
    } catch {
      throw new EndpointError("Session Expired", 403);
    }
    // TODO actual authentication
    return UserLoginResponse.fromPlain({ user: user, jwt: user.JWT });
  }
}
