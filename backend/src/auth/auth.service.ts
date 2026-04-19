import { MobileTokenExchangeDto } from "@backend/auth/model/api/mobile.token.exchange.dto";
import { Configuration } from "@backend/config/core";
import { User } from "@backend/user/model/user.model";
import { HttpService } from "@nestjs/axios";
import { HttpException, Injectable, Logger, UnauthorizedException } from "@nestjs/common";
import { Request, Response } from "express";
import jwt from "jsonwebtoken";
import { firstValueFrom } from "rxjs";
import { UsernamePasswordLoginRequest } from "./model/api/login.request.dto";

/** JWT object content that will be included when we create the JWT's in local authentication mode. */
export type LocalJWTContent = { username: string };

/** This service is used to validate login requests */
@Injectable()
export class AuthService {
  private readonly logger = new Logger("service:auth");
  // Allowed mobile schemes for redirect of OIDC auth
  static readonly ALLOWED_MOBILE_SCHEME = "net.croudebush.sprout";
  /** The cookie name we store the id token in. */
  static readonly idTokenCookie = "id";
  /** The cookie name we store the access token in. */
  static readonly accessTokenCookie = "at";
  /** The cookie name we store the refresh token in. */
  static readonly refreshCookie = "r";

  constructor(private readonly httpService: HttpService) {}

  /** Returns the cookie value for the given cookie */
  getCookie(cookie: "id" | "access" | "refresh", request: Request) {
    if (cookie === "id") return request.cookies[AuthService.idTokenCookie];
    else if (cookie == "access") return request.cookies[AuthService.accessTokenCookie];
    else return request.cookies[AuthService.refreshCookie] ?? request.headers["x-refresh-token"];
  }

  /** Clears all the cookie tokens and resets them to empty */
  clearAllCookieTokens(res: Response) {
    res.clearCookie(AuthService.idTokenCookie);
    res.clearCookie(AuthService.accessTokenCookie);
    res.clearCookie(AuthService.refreshCookie);
  }

  /** Sets tokens into the cookies based on what tokens you can provide */
  setCookieTokens(res: Response, idToken: string, accessToken?: string, refreshToken?: string) {
    const secure = !Configuration.isDevBuild;
    const sameSite = "strict";
    res.cookie(AuthService.idTokenCookie, idToken, { httpOnly: true, secure, sameSite });
    if (accessToken) res.cookie(AuthService.accessTokenCookie, accessToken, { httpOnly: true, secure, sameSite });
    if (refreshToken) res.cookie(AuthService.refreshCookie, refreshToken, { httpOnly: true, secure, sameSite });
  }

  /** Given a login request from an endpoint, requests a login by validating the username and password. */
  async login(loginRequest: UsernamePasswordLoginRequest) {
    const matchingUser = await User.findOne({ where: { username: loginRequest.username } });
    if (matchingUser == null || !matchingUser.password) throw new UnauthorizedException("Login failed");
    const passwordMatches = matchingUser.verifyPassword(loginRequest.password);
    if (!passwordMatches) throw new UnauthorizedException("Login failed");
    else return { user: matchingUser, jwt: this.generateJWT(matchingUser) };
  }

  /** Given a login request from an endpoint, requests a login by validating the JWT. */
  async loginWithJWT(jwt: string) {
    try {
      this.verifyJWT(jwt);
    } catch {
      throw new UnauthorizedException(!jwt ? "" : "Session Expired");
    }
    const usernameToCheck = this.decodeJWT(jwt).username;
    const matchingUser = await User.findOne({ where: { username: usernameToCheck } });
    if (matchingUser == null || matchingUser.password == null) throw new UnauthorizedException("Login failed");
    else return { user: matchingUser, jwt: this.generateJWT(matchingUser) };
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

  /** Determines based on the request if it came from the web or a mobile app. We set this platform header ourselves. */
  getPlatform(request: Request) {
    return request.headers["x-client-platform"] as "mobile" | "web";
  }

  /**
   * This function is used to attempt to refresh our ID token from our OIDC provider
   *  based on the given refresh token. If it fails to refresh, it will throw an exception.
   */
  async performOIDCRefresh(req: Request, res?: Response) {
    const { issuer, authHeader } = Configuration.server.auth.oidc;
    const refreshToken = this.getCookie("refresh", req);
    if (!refreshToken) throw new UnauthorizedException("No refresh token provided");

    try {
      const response = await firstValueFrom(
        this.httpService.post(
          `${issuer}/api/oidc/token`,
          new URLSearchParams({
            grant_type: "refresh_token",
            refresh_token: refreshToken,
          }).toString(),
          {
            headers: {
              "Content-Type": "application/x-www-form-urlencoded",
              Authorization: `Basic ${authHeader}`,
            },
          },
        ),
      );

      if (response.status !== 200) throw new HttpException(response.statusText, response.status);

      const { access_token, refresh_token, id_token } = response.data;
      // Set our cookie content, if response is given
      if (res) this.setCookieTokens(res, id_token, access_token, refresh_token);
      return new MobileTokenExchangeDto(id_token, access_token, refresh_token);
    } catch (e: any) {
      this.logger.error(`Refresh failed: ${e.message}`);
      // If the OIDC provider returns 401, we propagate it as a session death
      throw new UnauthorizedException("Session expired and could not be refreshed.");
    }
  }

  /**
   * Given a token, asks the OIDC provider to introspect it to obtain information about our actual token
   *  including active state, issue time, and expiration time.
   */
  async introspectToken(token: string): Promise<{ active: boolean; iat?: number; exp?: number }> {
    const { issuer, authHeader } = Configuration.server.auth.oidc;
    try {
      const response = await firstValueFrom(
        this.httpService.post(`${issuer}/api/oidc/introspection`, new URLSearchParams({ token }).toString(), {
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            Authorization: `Basic ${authHeader}`,
          },
        }),
      );
      return response.data;
    } catch (e) {
      this.logger.error(`Introspection failed: ${e}`);
      return { active: false };
    }
  }
}
