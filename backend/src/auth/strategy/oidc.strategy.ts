import { AuthService } from "@backend/auth/auth.service";
import { OIDCIDTokenIntrospectionResult } from "@backend/auth/model/oidc.introspection";
import { extractJwtFromHeaderOrCookie } from "@backend/auth/strategy/auth.extractor";
import { Configuration } from "@backend/config/core";
import { User } from "@backend/user/model/user.model";
import { UserSetupContext } from "@backend/user/model/user.setup.context.model";
import { HttpService } from "@nestjs/axios";
import { CACHE_MANAGER, Cache } from "@nestjs/cache-manager";
import { HttpException, Inject, Injectable, Logger, UnauthorizedException } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import { isAxiosError } from "axios";
import { Request } from "express";
import { passportJwtSecret } from "jwks-rsa";
import { ExtractJwt, Strategy } from "passport-jwt";
import { firstValueFrom } from "rxjs";

export const OIDCStrategyName = "oidc";

type ProfileData = { sub: string; preferred_username: string; email: string };

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

  async validate(req: Request, data: any) {
    const profileIntrospect = OIDCIDTokenIntrospectionResult.fromPlain(data);
    let profileData: ProfileData | undefined;

    // Perform some security validation
    profileIntrospect.checkIssuedState();

    // Check if we need to refresh
    if (profileIntrospect.isExpired) {
      this.logger.debug(`Token expired or inactive for request, attempting refresh.`);
      try {
        const tokens = await this.authService.performOIDCRefresh(req, req.res);
        // Update profileData with the new token's claims so the current request succeeds
        profileData = await this.getUserInfo(tokens.accessToken);
        this.logger.debug(`Token refreshed successfully.`);
      } catch (e) {
        this.logger.error(`Refresh failed: ${e}`);
        throw new UnauthorizedException("Session expired.");
      }
    } else {
      const accessToken = this.authService.getCookie("access", req);
      profileData = await this.getUserInfo(accessToken);
    }

    // Make sure we have the user info
    if (!profileData?.preferred_username) throw new UnauthorizedException("Could not determine username from token.");
    // Find user based on our profile data
    const user = await User.findOne({ where: { id: profileData.sub } });
    // Set request context for any data we have for setup of new users
    (req as any).setupUser = new UserSetupContext(profileData.sub, profileData.preferred_username, profileData.email);
    // No user? Probably should fail then
    if (!user) throw new UnauthorizedException(`User ${profileData.preferred_username} not found`);
    return user;
  }

  /**
   * Retrieves the user info from the OIDC endpoint/cache and returns it
   */
  private async getUserInfo(accessToken: string): Promise<ProfileData> {
    const cacheKey = `oidc_user_${accessToken}`;
    // Check if we have cache data
    let profileData = await this.cacheManager.get<any>(cacheKey);

    // If no cache data, grab it from OIDC provider
    if (!profileData) {
      // Grab the user profile info from the remote OIDC endpoint
      const userInfoUrl = `${Configuration.server.auth.oidc.issuer}/api/oidc/userinfo`;
      try {
        const response = await firstValueFrom(
          this.httpService.get(userInfoUrl, {
            headers: { Authorization: `Bearer ${accessToken}` },
          }),
        );

        if (response.status !== 200) throw new HttpException(response.statusText, response.status);
        profileData = response.data;

        // Cache our data so we don't over-request. Save it for 5 minutes.
        await this.cacheManager.set(cacheKey, profileData, 5 * 60000);
      } catch (e) {
        if (isAxiosError(e) && e.status !== 200) throw new HttpException(e.message, e.status!);
      }
    }
    return profileData;
  }
}
