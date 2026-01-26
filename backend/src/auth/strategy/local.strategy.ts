import { LocalJWTContent } from "@backend/auth/auth.service";
import { extractJwtFromHeaderOrCookie } from "@backend/auth/strategy/auth.extractor";
import { Configuration } from "@backend/config/core";
import { User } from "@backend/user/model/user.model";
import { Injectable, UnauthorizedException } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import { ExtractJwt, Strategy } from "passport-jwt";

export const LocalStrategyName = "local";

/** This strategy is used for authentication to configure parsing our jwt that will have been signed from our backend */
@Injectable()
export class LocalStrategy extends PassportStrategy(Strategy, "local") {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromExtractors([extractJwtFromHeaderOrCookie]),
      secretOrKey: Configuration.server.auth.secretKey,
      ignoreExpiration: false,
    });
  }

  async validate(payload: LocalJWTContent) {
    const user = await User.findOne({ where: { username: payload.username } });
    if (!user) throw new UnauthorizedException();
    return user;
  }
}
