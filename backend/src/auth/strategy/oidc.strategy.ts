import { AuthService } from "@backend/auth/auth.service";
import { extractJwtFromHeaderOrCookie } from "@backend/auth/strategy/auth.extractor";
import { Configuration } from "@backend/config/core";
import { User } from "@backend/user/model/user.model";
import { UserSetupContext } from "@backend/user/model/user.setup.context.model";
import { HttpService } from "@nestjs/axios";
import { CACHE_MANAGER, Cache } from "@nestjs/cache-manager";
import { Inject, Injectable, Logger, UnauthorizedException } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import { Request } from "express";
import { passportJwtSecret } from "jwks-rsa";
import { ExtractJwt, Strategy } from "passport-jwt";
import { firstValueFrom } from "rxjs";

export const OIDCStrategyName = "oidc";

@Injectable()
export class OIDCStrategy extends PassportStrategy(Strategy, "oidc") {
  private readonly logger = new Logger("strategy:oidc");

  constructor(
    private readonly httpService: HttpService,
    private readonly authService: AuthService,
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
  ) {
    const config = Configuration.server.auth.oidc;
    // Grab config we need. We default to temp as validate will be executed in main
    const issuer = config.issuer || "temp";
    const audience = config.clientId || "temp";
    super({
      jwtFromRequest: ExtractJwt.fromExtractors([extractJwtFromHeaderOrCookie]),
      secretOrKeyProvider: passportJwtSecret({
        cache: true,
        rateLimit: true,
        jwksRequestsPerMinute: 5,
        jwksUri: `${issuer}/jwks.json`,
      }),
      passReqToCallback: true,
      issuer: issuer,
      audience,
      ignoreExpiration: true, // Ignores expiration so we can auto refresh
    });
  }

  async validate(req: Request, profile: { iss: string; exp: number; sub: string; aud: Array<string> }) {
    const config = Configuration.server.auth.oidc;
    const now = Math.floor(Date.now() / 1000);
    let profileData: { sub: string; preferred_username: string } | undefined;

    // Perform some security validation
    if (profile.iss !== config.issuer) throw new UnauthorizedException("Invalid token issuer.");
    if (!profile.aud.includes(config.clientId)) throw new UnauthorizedException("Invalid token audience.");

    // Grab some tokens from cookies, if available
    const refreshToken = req.cookies[AuthService.refreshCookie];
    const accessToken = req.cookies[AuthService.accessTokenCookie];
    // Check if we need to refresh
    if (profile.exp && now >= profile.exp) {
      this.logger.debug(`Token expired for ${profile.sub}, attempting refresh...`);

      if (!refreshToken) throw new UnauthorizedException("Session expired and no refresh token available.");

      try {
        const tokens = await this.authService.performOIDCRefresh(refreshToken, req.res);

        // Update profileData with the new token's claims so the current request succeeds
        profileData = await this.getUserInfo(tokens.accessToken);
      } catch (e) {
        this.logger.error(`Refresh failed: ${e}`);
        throw new UnauthorizedException("Session expired.");
      }
    } else {
      // No refresh? Grab profile data
      profileData = await this.getUserInfo(accessToken);
    }

    // Make sure we have the user info
    if (!profileData?.preferred_username) throw new UnauthorizedException("Could not determine username from token.");
    // Find user based on our profile data/token
    const user = await User.findOne({ where: { username: profileData.preferred_username } });
    // Set request context for any data we have for setup of new users
    (req as any).setupUser = new UserSetupContext(profileData.sub, profileData.preferred_username);
    // No user? Probably should fail then
    if (!user) throw new UnauthorizedException(`User ${profileData.preferred_username} not found`);
    return user;
  }

  /**
   * Retrieves the user info from the OIDC endpoint/cache and returns it
   */
  private async getUserInfo(accessToken: string) {
    const cacheKey = `oidc_user_${accessToken}`;
    // Check if we have cache data
    let profileData = await this.cacheManager.get<any>(cacheKey);

    // If no cache data, grab it from OIDC provider
    if (!profileData) {
      // Grab the user profile info from the remote OIDC endpoint
      const userInfoUrl = `${Configuration.server.auth.oidc.issuer}/api/oidc/userinfo`;
      profileData = (
        await firstValueFrom(
          this.httpService.get(userInfoUrl, {
            headers: { Authorization: `Bearer ${accessToken}` },
          }),
        )
      ).data;

      // Cache our data so we don't over-request. Save it for 5 minutes.
      await this.cacheManager.set(cacheKey, profileData, 5 * 60000);
    }
    return profileData;
  }
}
