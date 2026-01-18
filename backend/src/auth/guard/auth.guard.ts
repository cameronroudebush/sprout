import { LocalStrategyName } from "@backend/auth/strategy/local.strategy";
import { OIDCStrategyName } from "@backend/auth/strategy/oidc.strategy";
import { Configuration } from "@backend/config/core";
import { applyDecorators, Injectable, UseGuards } from "@nestjs/common";
import { AuthGuard as PassportAuthGuard } from "@nestjs/passport";
import { ApiBearerAuth, ApiUnauthorizedResponse } from "@nestjs/swagger";

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
  /** Dynamically attaches the expected guards and response indication for our authentication to endpoints */
  static attach() {
    return applyDecorators(ApiUnauthorizedResponse({ description: "Authentication is required." }), ApiBearerAuth(), UseGuards(AuthGuard));
  }
}
