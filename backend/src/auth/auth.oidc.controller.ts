import { StrategyGuard } from "@backend/auth/guard/strategy.guard";
import { MobileTokenExchangeDto } from "@backend/auth/model/api/mobile.token.exchange.dto";
import { Configuration } from "@backend/config/core";
import { PublicURL } from "@backend/core/decorator/public.url.decorator";
import { HttpService } from "@nestjs/axios";
import { BadRequestException, Body, Controller, Get, HttpCode, HttpStatus, Logger, Put, Query, Req, Res, UnauthorizedException } from "@nestjs/common";
import { ApiOperation, ApiResponse, ApiTags } from "@nestjs/swagger";
import { createHash, randomBytes } from "crypto";
import { Request, Response } from "express";
import { firstValueFrom } from "rxjs";
import { AuthService } from "./auth.service";

/** This controller provides the related to OIDC specific authentication. */
@Controller("auth/oidc")
@ApiTags("Auth")
@StrategyGuard.attach("oidc")
export class OIDCController {
  private readonly logger = new Logger("controller:auth:oidc");

  constructor(
    private readonly authService: AuthService,
    private readonly httpService: HttpService,
  ) {}

  @Get("login")
  @ApiOperation({
    summary: "Authenticates using the OIDC configuration.",
    description:
      "Authenticates to our OIDC server that is configured and handles redirecting the authentication capability back to API to complete the login request.",
  })
  async loginOIDC(@Query("target_url") targetUrl: string, @Res() res: Response, @PublicURL() publicUrl: string) {
    // Ensure the target URL is either a relative path, matches our public URL, or is the allowed mobile scheme
    if (!this.authService.isValidRedirectUrl(targetUrl, publicUrl)) throw new BadRequestException("Invalid target URL provided.");

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

  @Get("callback")
  @ApiOperation({
    summary: "Callback handler for the OIDC login.",
    description: "Handles the redirect back from the OIDC server and handles state control to get the authentication response back to the original requester.",
  })
  async loginCallbackOIDC(
    @Query("code") code: string,
    @Query("state") state: string,
    @Req() req: Request,
    @Res() res: Response,
    @PublicURL() publicUrl: string,
  ) {
    const { issuer, authHeader } = Configuration.server.auth.oidc;

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
            code: code,
            redirect_uri: redirectUri,
            code_verifier: codeVerifier,
          }).toString(),
          { headers: { "Content-Type": "application/x-www-form-urlencoded", Authorization: `Basic ${authHeader}` } },
        ),
      );

      const { id_token, access_token, refresh_token } = response.data;
      // Clear the temporary cookie
      res.clearCookie("oidc_pending");

      // We validate again to ensure the cookie wasn't tampered with (though it is signed) or that the logic hasn't drifted.
      if (!this.authService.isValidRedirectUrl(targetUrl, publicUrl)) {
        this.logger.warn(`Open redirect attempt detected to: ${targetUrl}`);
        throw new UnauthorizedException("Invalid redirect target");
      }

      // Always set cookies for tracking
      this.authService.setCookieTokens(res, id_token, access_token, refresh_token);
      const isMobileScheme = targetUrl.startsWith(AuthService.ALLOWED_MOBILE_SCHEME);
      // Include the tokens in the mobile response so it can exchange them for cookies
      if (isMobileScheme) {
        const redirectUrl = new URL(targetUrl);
        redirectUrl.searchParams.set("id_token", id_token);
        redirectUrl.searchParams.set("access_token", access_token);
        redirectUrl.searchParams.set("refresh_token", refresh_token);
        return res.redirect(redirectUrl.toString());
      } else return res.redirect(targetUrl);
    } catch (e) {
      this.logger.error(e);
      throw new UnauthorizedException("Auth failed");
    }
  }

  @Put("exchange")
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: "Exchange OIDC tokens for HttpOnly cookies",
    description: "This seeds the mobile CookieJar or Browser cookies.",
  })
  @ApiResponse({ status: 204, description: "Cookies set successfully" })
  @ApiResponse({ status: 400, description: "Invalid token DTO" })
  async exchange(@Body() tokens: MobileTokenExchangeDto, @Req() req: Request, @Res({ passthrough: true }) res: Response) {
    const currentAccessToken = this.authService.getCookie("access", req);
    if (currentAccessToken) {
      // Ask the OIDC provider about the current cookie and the new token
      const [currentMeta, newMeta] = await Promise.all([
        this.authService.introspectToken(currentAccessToken),
        this.authService.introspectToken(tokens.accessToken),
      ]);

      // If the cookie token is active and was issued AFTER (or same time as)
      // the incoming token, ignore the request.
      if (currentMeta.active && currentMeta.iat && newMeta.iat)
        if (currentMeta.iat >= newMeta.iat) {
          this.logger.debug("Exchange ignored: Cookie has a more recent token session.");
          return;
        }
    }
    this.authService.setCookieTokens(res, tokens.idToken, tokens.accessToken, tokens.refreshToken);
  }
}
