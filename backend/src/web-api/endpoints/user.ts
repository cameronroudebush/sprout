import { User } from "@backend/model/user";
import { RestBody, RestEndpoints, UserLoginRequest, UserLoginResponse } from "@common";
import { EndpointError } from "../error";
import { RestMetadata } from "../metadata";

export class UserAPI {
  @RestMetadata.register(new RestMetadata(RestEndpoints.user.login, "POST", false))
  async login(request: RestBody) {
    const userRequest = UserLoginRequest.fromPlain(request.payload);
    const matchingUser = await User.findOne({ where: { username: userRequest.username } });
    if (matchingUser == null) throw new EndpointError("Login failed", 403);
    const passwordMatches = matchingUser.verifyPassword(userRequest.password);
    if (!passwordMatches) throw new EndpointError("Login failed", 403);
    else return UserLoginResponse.fromPlain({ user: matchingUser, jwt: matchingUser.JWT });
  }

  @RestMetadata.register(new RestMetadata(RestEndpoints.user.loginJWT, "POST", false))
  async loginWithJWT(request: RestBody) {
    const userRequest = UserLoginRequest.fromPlain(request.payload);
    const jwt = userRequest.jwt!;
    try {
      User.verifyJWT(jwt);
    } catch {
      throw new EndpointError("Session Expired", 403);
    }
    const usernameToCheck = User.decodeJWT(jwt).username;
    const matchingUser = await User.findOne({ where: { username: usernameToCheck } });
    if (matchingUser == null) throw new EndpointError("Login failed", 403);
    else return UserLoginResponse.fromPlain({ user: matchingUser, jwt });
  }
}
