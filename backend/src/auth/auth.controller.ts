import { StrategyGuard } from "@backend/auth/guard/strategy.guard";
import { RefreshRequestDTO } from "@backend/auth/model/api/refresh.request.dto";
import { RefreshResponseDTO } from "@backend/auth/model/api/refresh.response.dto";
import { extractJwtFromHeaderOrCookie } from "@backend/auth/strategy/auth.extractor";
import { Configuration } from "@backend/config/core";
import { PublicURL } from "@backend/core/decorator/public.url.decorator";
import { HttpService } from "@nestjs/axios";
import { Body, Controller, Get, Logger, Post, Query, Req, Res, UnauthorizedException } from "@nestjs/common";
import { ApiBody, ApiCreatedResponse, ApiOkResponse, ApiOperation, ApiTags, ApiUnauthorizedResponse } from "@nestjs/swagger";
import { createHash, randomBytes } from "crypto";
import { Request, Response } from "express";
import { firstValueFrom } from "rxjs";
import { AuthService } from "./auth.service";
import { JWTLoginRequest, UsernamePasswordLoginRequest } from "./model/api/login.request.dto";
import { UserLoginResponse } from "./model/api/login.response.dto";

/** This controller provides the endpoints for authentication related capabilities. */
@Controller("auth")
@ApiTags("Auth")
export class AuthController {
  private readonly logger = new Logger();

  constructor(
    private readonly authService: AuthService,
    private readonly httpService: HttpService,
  ) {}

  @Post("login")
  @ApiOperation({
    summary: "Login with username and password.",
    description:
      "Authenticates a user with their username and password, returning user details and a new JWT for requests. Only available on local strategy auth.",
  })
  @ApiCreatedResponse({ description: "User login successful.", type: UserLoginResponse })
  @ApiUnauthorizedResponse({ description: "Invalid credentials provided." })
  @ApiBody({ type: UsernamePasswordLoginRequest })
  @StrategyGuard.attach("local")
  async login(@Body() body: UsernamePasswordLoginRequest, @Res({ passthrough: true }) res: Response, @Req() req: Request): Promise<UserLoginResponse> {
    const platform = req.headers["x-client-platform"] as "mobile" | "web";
    const response = await this.authService.login(body);
    // Exclude the JWT from the response on web to prevent XSS with the JWT. We use cookies instead.
    if (platform === "web") {
      this.setCookieTokens(res, response.jwt!);
      response.jwt = undefined;
    }
    return response;
  }

  @Post("login/jwt")
  @ApiOperation({
    summary: "Login with an existing JWT.",
    description: "Validates an existing JWT. If valid, it returns the user details and the same JWT. Only available on local strategy auth.",
  })
  @ApiCreatedResponse({ description: "User login successful.", type: UserLoginResponse })
  @ApiUnauthorizedResponse({ description: "The provided JWT is invalid or has expired." })
  @ApiBody({ type: JWTLoginRequest })
  @StrategyGuard.attach("local")
  async loginWithJWT(@Body() body: JWTLoginRequest, @Req() req: Request, @Res({ passthrough: true }) res: Response): Promise<UserLoginResponse> {
    const platform = req.headers["x-client-platform"] as "mobile" | "web";
    const token = extractJwtFromHeaderOrCookie(req) || body.jwt;
    if (token == null) throw new UnauthorizedException();
    const response = await this.authService.loginWithJWT(token);
    // Exclude the JWT from the response on web. Update the cookie.
    if (platform === "web") {
      this.setCookieTokens(res, response.jwt!);
      response.jwt = undefined;
    }
    return response;
  }

  /** Sets tokens into the cookies based on what tokens you can provide */
  private setCookieTokens(res: Response, idToken: string, accessToken?: string, refreshToken?: string) {
    const secure = !Configuration.isDevBuild;
    res.cookie("id_token", idToken, { httpOnly: true, secure });
    if (accessToken) res.cookie("access_token", accessToken, { httpOnly: true, secure });
    if (refreshToken) res.cookie("refresh_token", refreshToken, { httpOnly: true, secure, path: "/auth/oidc/refresh" });
  }

  @Post("oidc/refresh")
  @ApiOperation({
    summary: "Proxy OIDC refresh requests.",
    description: "Proxies OIDC token refresh to the destination server of the OIDC issuer.  Only available on OIDC strategy auth.",
  })
  @ApiOkResponse({ type: RefreshResponseDTO })
  @StrategyGuard.attach("oidc")
  async refresh(@Body() dto: RefreshRequestDTO, @Req() req: Request, @Res({ passthrough: true }) res: Response) {
    const { issuer, clientId } = Configuration.server.auth.oidc;
    // Grab token from cookie and fallback to DTO
    const refreshToken = req.cookies["refresh_token"] || dto.refreshToken;

    if (!refreshToken) throw new UnauthorizedException("No refresh token provided");

    try {
      const response = await firstValueFrom(
        this.httpService.post(
          `${issuer}/api/oidc/token`,
          new URLSearchParams({
            grant_type: "refresh_token",
            refresh_token: refreshToken,
            client_id: clientId,
          }).toString(),
          { headers: { "Content-Type": "application/x-www-form-urlencoded" } },
        ),
      );

      // If the token was in the cookie, go ahead and update them. This means web so we don't need to send info back
      if (req.cookies["refresh_token"]) {
        const { access_token, refresh_token, id_token } = response.data;
        this.setCookieTokens(res, id_token, access_token, refresh_token);
        return new RefreshResponseDTO("", "", "");
      }

      // If Mobile, return tokens in Body
      return new RefreshResponseDTO(response.data.id_token, response.data.access_token, response.data.refresh_token);
    } catch (e: any) {
      throw new UnauthorizedException("Session could not be refreshed.");
    }
  }

  @Get("oidc/login")
  @ApiOperation({
    summary: "Authenticates using the OIDC configuration.",
    description:
      "Authenticates to our OIDC server that is configured and handles redirecting the authentication capability back to API to complete the login request.",
  })
  @StrategyGuard.attach("oidc")
  async loginOIDC(@Query("target_url") targetUrl: string, @Res() res: Response, @PublicURL() publicUrl: string) {
    const { issuer, clientId } = Configuration.server.auth.oidc;
    const redirectUri = `${publicUrl}${Configuration.server.basePath}/auth/oidc/callback`;
    // Security state
    const state = randomBytes(16).toString("hex");
    const codeVerifier = randomBytes(32).toString("base64url");
    const codeChallenge = createHash("sha256").update(codeVerifier).digest("base64url");
    // Store security configuration into a cookie
    res.cookie("oidc_pending", JSON.stringify({ state, codeVerifier, targetUrl, redirectUri }), {
      httpOnly: true,
      signed: true,
      secure: !Configuration.isDevBuild,
      maxAge: 5 * 60000, // 5 Minutes
    });

    // Create the params that contain all of the information for our authentication challenge
    const params = new URLSearchParams({
      client_id: clientId,
      response_type: "code",
      redirect_uri: redirectUri,
      scope: Configuration.server.auth.oidc.scopes.join(" "),
      state: state,
      code_challenge: codeChallenge,
      code_challenge_method: "S256",
    });

    return res.redirect(`${issuer}/api/oidc/authorization?${params.toString()}`);
  }

  @Get("oidc/callback")
  @ApiOperation({
    summary: "Callback handler for the OIDC login.",
    description: "Handles the redirect back from the OIDC server and handles state control to get the authentication response back to the original requester.",
  })
  @StrategyGuard.attach("oidc")
  async loginCallbackOIDC(@Query("code") code: string, @Query("state") state: string, @Req() req: Request, @Res() res: Response) {
    const { issuer, clientId } = Configuration.server.auth.oidc;

    // Validate Cookie
    const pendingCookie = req.signedCookies["oidc_pending"];
    if (!pendingCookie) throw new UnauthorizedException("Session expired");

    const { state: storedState, codeVerifier, targetUrl, redirectUri } = JSON.parse(pendingCookie);
    if (state !== storedState) throw new UnauthorizedException("State mismatch");

    try {
      // Exchange Code for Tokens
      const response = await firstValueFrom(
        this.httpService.post(
          `${issuer}/api/oidc/token`,
          new URLSearchParams({
            grant_type: "authorization_code",
            client_id: clientId,
            code: code,
            redirect_uri: redirectUri,
            code_verifier: codeVerifier,
          }).toString(),
          { headers: { "Content-Type": "application/x-www-form-urlencoded" } },
        ),
      );

      const { id_token, access_token, refresh_token } = response.data;
      // Clear the temporary cookie
      res.clearCookie("oidc_pending");

      // Detect if this is a Mobile Deep Link or a Web URL
      const isMobileScheme = targetUrl.startsWith("net.croudebush.sprout");

      if (isMobileScheme) {
        // Mobile - Fragments
        const finalUrl = new URL(targetUrl);
        // Mobile apps need the tokens in the URL to capture them
        finalUrl.hash = `id_token=${id_token}&access_token=${access_token}&refresh_token=${refresh_token}`;
        return res.redirect(finalUrl.toString());
      } else {
        // Web - Cookies
        this.setCookieTokens(res, id_token, access_token, refresh_token);
        return res.redirect(targetUrl);
      }
    } catch (e) {
      this.logger.error(e);
      throw new UnauthorizedException("Auth failed");
    }
  }

  @Post("logout")
  @ApiOperation({ summary: "Logout the user", description: "Clears the session cookies any authentication that has happened." })
  async logout(@Res({ passthrough: true }) res: Response) {
    res.clearCookie("id_token");
    res.clearCookie("access_token");
    res.clearCookie("refresh_token");
    return { success: true };
  }
}
