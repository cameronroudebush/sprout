import { UserLoginResponse } from "@backend/user/model/api/login.response";
import { User } from "@backend/user/model/user";
import { Injectable, UnauthorizedException } from "@nestjs/common";
import { JWTLoginRequest, UsernamePasswordLoginRequest } from "./model/api/login.request";

@Injectable()
export class UserService {
  /** Given a login request from an endpoint, requests a login by validating the username and password. */
  async login(loginRequest: UsernamePasswordLoginRequest): Promise<UserLoginResponse> {
    const matchingUser = await User.findOne({ where: { username: loginRequest.username } });
    if (matchingUser == null) throw new UnauthorizedException("Login failed");
    const passwordMatches = matchingUser.verifyPassword(loginRequest.password);
    if (!passwordMatches) throw new UnauthorizedException("Login failed");
    else return UserLoginResponse.fromPlain({ user: matchingUser, jwt: matchingUser.JWT });
  }

  /** Given a login request from an endpoint, requests a login by validating the JWT. */
  async loginWithJWT(loginRequest: JWTLoginRequest): Promise<UserLoginResponse> {
    const jwt = loginRequest.jwt!;
    try {
      User.verifyJWT(jwt);
    } catch {
      throw new UnauthorizedException("Session Expired");
    }
    const usernameToCheck = User.decodeJWT(jwt).username;
    const matchingUser = await User.findOne({ where: { username: usernameToCheck } });
    if (matchingUser == null) throw new UnauthorizedException("Login failed");
    else return UserLoginResponse.fromPlain({ user: matchingUser, jwt });
  }
}
