import { Configuration } from "@backend/config/core";
import { User } from "@backend/user/model/user.model";
import { Injectable, UnauthorizedException } from "@nestjs/common";
import jwt from "jsonwebtoken";
import { UsernamePasswordLoginRequest } from "./model/api/login.request.dto";
import { UserLoginResponse } from "./model/api/login.response.dto";

/** JWT object content that will be included when we create the JWT's in local authentication mode. */
export type LocalJWTContent = { username: string };

/** This service is used to validate login requests */
@Injectable()
export class AuthService {
  // Allowed mobile schemes for redirect of OIDC auth
  static readonly ALLOWED_MOBILE_SCHEME = "net.croudebush.sprout";

  /** Given a login request from an endpoint, requests a login by validating the username and password. */
  async login(loginRequest: UsernamePasswordLoginRequest): Promise<UserLoginResponse> {
    const matchingUser = await User.findOne({ where: { username: loginRequest.username } });
    if (matchingUser == null || !matchingUser.password) throw new UnauthorizedException("Login failed");
    const passwordMatches = matchingUser.verifyPassword(loginRequest.password);
    if (!passwordMatches) throw new UnauthorizedException("Login failed");
    else return UserLoginResponse.fromPlain({ user: matchingUser, jwt: this.generateJWT(matchingUser) });
  }

  /** Given a login request from an endpoint, requests a login by validating the JWT. */
  async loginWithJWT(jwt: string): Promise<UserLoginResponse> {
    try {
      this.verifyJWT(jwt);
    } catch {
      throw new UnauthorizedException(!jwt ? "" : "Session Expired");
    }
    const usernameToCheck = this.decodeJWT(jwt).username;
    const matchingUser = await User.findOne({ where: { username: usernameToCheck } });
    if (matchingUser == null || matchingUser.password == null) throw new UnauthorizedException("Login failed");
    else return UserLoginResponse.fromPlain({ user: matchingUser, jwt });
  }

  /** Verifies the given JWT. Throws an error if it is not valid */
  verifyJWT(jwtString?: string) {
    if (!jwtString) throw new Error("Invalid JWT");
    return jwt.verify(jwtString, Configuration.server.auth.secretKey) as LocalJWTContent;
  }

  /** Decodes the given JWT to get relevant content from it */
  private decodeJWT(token: string) {
    return jwt.decode(token) as LocalJWTContent;
  }

  /** Signs a JWT for the given user */
  private generateJWT(user: User) {
    return jwt.sign({ username: user.username } as LocalJWTContent, Configuration.server.auth.secretKey, {
      expiresIn: Configuration.server.auth.local.jwtExpirationTime,
    } as any);
  }

  /**
   * Helper to validate that the target URL is safe to redirect to.
   * It must be either:
   * 1. A relative URL (starts with /)
   * 2. The same origin as the public URL
   * 3. The allowed mobile scheme
   */
  isValidRedirectUrl(targetUrl: string, publicUrl: string): boolean {
    if (!targetUrl) return false;
    // Allow internal relative paths
    if (targetUrl.startsWith("/")) return true;
    // Allow specific mobile scheme
    if (targetUrl.startsWith(AuthService.ALLOWED_MOBILE_SCHEME)) return true;

    try {
      const target = new URL(targetUrl);
      const source = new URL(publicUrl);
      // Compare Hostnames (e.g. api.mysite.com vs mysite.com or localhost vs localhost)
      return target.hostname === source.hostname;
    } catch (e) {
      // Invalid URL format
      return false;
    }
  }
}
