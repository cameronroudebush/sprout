import { LocalStrategyName } from "@backend/auth/local.strategy";
import { OIDCStrategyName } from "@backend/auth/oidc.strategy";
import { Configuration } from "@backend/config/core";
import { Injectable, UseGuards } from "@nestjs/common";
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
    return function <TFunction extends Function>(target: Object, propertyKey?: string | symbol, descriptor?: TypedPropertyDescriptor<TFunction>) {
      ApiUnauthorizedResponse({ description: "Authentication is required." })(target, propertyKey!, descriptor!);
      ApiBearerAuth()(target, propertyKey!, descriptor!);
      UseGuards(AuthGuard)(target, propertyKey!, descriptor!);
    };
  }
}
