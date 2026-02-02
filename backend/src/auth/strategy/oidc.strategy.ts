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
      ignoreExpiration: false,
    });
  }

  async validate(req: Request, profileData: { sub: string; preferred_username: string }) {
    // Sometimes the JWT may be minified which means it excludes all profile info. So go ahead and look that up manually.
    if (!profileData.preferred_username) {
      // Need the access token to request data from OIDC provider. Try and find it from either cookies or the header
      const accessToken = req.cookies["access_token"] || req.headers["x-access-token"];

      if (!accessToken) throw new UnauthorizedException("Token missing profile data and no access token provided.");

      if (accessToken) {
        const cacheKey = `oidc_user_${accessToken}`;
        try {
          // Check if we have cache data
          profileData = await this.cacheManager.get<any>(cacheKey);

          // If no cache data, grab it from OIDC
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
          }

          // Cache our data so we don't over-request. Save it for 5 minutes.
          await this.cacheManager.set(cacheKey, profileData, 5 * 60000);
        } catch (e) {
          this.logger.error(`Failed to fetch UserInfo: ${e}`);
        }
      } else this.logger.warn("ID Token missing claims and no x-access-token header provided.");
    }

    if (!profileData?.preferred_username) throw new UnauthorizedException("Could not determine username from token.");

    // Find user based on our profile data/token
    const user = await User.findOne({ where: { username: profileData.preferred_username } });

    // Set request context for any data we have for setup of new users
    (req as any).setupUser = new UserSetupContext(profileData.sub, profileData.preferred_username);

    // No user? Probably should fail then
    if (!user) throw new UnauthorizedException(`User ${profileData.preferred_username} not found`);

    return user;
  }
}
