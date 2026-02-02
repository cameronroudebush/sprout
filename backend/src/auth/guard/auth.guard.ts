import { LocalStrategyName } from "@backend/auth/strategy/local.strategy";
import { OIDCStrategyName } from "@backend/auth/strategy/oidc.strategy";
import { Configuration } from "@backend/config/core";
import { User } from "@backend/user/model/user.model";
import { applyDecorators, ExecutionContext, Injectable, SetMetadata, UnauthorizedException, UseGuards } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { AuthGuard as PassportAuthGuard } from "@nestjs/passport";
import { ApiBearerAuth, ApiUnauthorizedResponse } from "@nestjs/swagger";

/** Metadata key that we track if endpoints may allow anonymous usage. */
const ALLOW_ANON_KEY = "allow_anon";

/**
 * Helper to determine which strategies to enable based on environment.
 */
function getAuthStrategies(): string[] {
  if (Configuration.server.auth.type === "oidc") return [OIDCStrategyName];
  else return [LocalStrategyName];
}

/** A guard that automatically handles trying to authenticate our local JWT and falls back to OIDC if available. */
@Injectable()
export class AuthGuard extends PassportAuthGuard(getAuthStrategies()) {
  constructor(private reflector: Reflector) {
    super();
  }

  /** Standard strict attachment. User MUST be authenticated. */
  static attach() {
    return applyDecorators(ApiUnauthorizedResponse({ description: "Authentication is required." }), ApiBearerAuth(), UseGuards(AuthGuard));
  }

  /** Optional attachment. If auth fails or is missing, request proceeds with user = null for {@link CurrentUser}. */
  static attachOptional() {
    return applyDecorators(
      SetMetadata(ALLOW_ANON_KEY, true), // Mark route as allowing failure
      ApiBearerAuth(), // Still document that it USES auth
      UseGuards(AuthGuard),
    );
  }

  override handleRequest(err: any, user: any, _info: any, context: ExecutionContext) {
    const allowAnon = this.reflector.get<boolean>(ALLOW_ANON_KEY, context.getHandler());
    // Success: Token is valid AND Strategy found a "user"
    if (user && user instanceof User) return user as any;
    // Failure: Check if we should allow anonymous access
    if (allowAnon) return null;
    // Strict mode
    throw err || new UnauthorizedException();
  }
}
