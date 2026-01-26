import { LocalStrategyName } from "@backend/auth/strategy/local.strategy";
import { OIDCStrategyName } from "@backend/auth/strategy/oidc.strategy";
import { Configuration } from "@backend/config/core";
import { applyDecorators, CanActivate, ExecutionContext, ForbiddenException, Injectable, SetMetadata, UseGuards } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { ApiExcludeEndpoint } from "@nestjs/swagger";

/**
 * This guard allows you to restrict your endpoints to only be available
 *  in the event specific strategies are available for authentication
 */
@Injectable()
export class StrategyGuard implements CanActivate {
  static readonly METADATA_KEY = "strategy_method";

  /** Dynamically attaches the strategy guard based on the configuration you give. For more info see {@link StrategyGuard} */
  static attach(method: typeof OIDCStrategyName | typeof LocalStrategyName) {
    return applyDecorators(
      SetMetadata(StrategyGuard.METADATA_KEY, method),
      UseGuards(StrategyGuard),
      Configuration.server.auth.type !== method && Configuration.isRunningScript === false ? ApiExcludeEndpoint() : () => {},
    );
  }

  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredMethod = this.reflector.get<string>(StrategyGuard.METADATA_KEY, context.getHandler());
    if (!requiredMethod) return true;

    const activeStrategy = Configuration.server.auth.type;

    if (activeStrategy !== requiredMethod) {
      throw new ForbiddenException(`This endpoint is disabled because the current auth strategy is ${activeStrategy}.`);
    }

    return true;
  }
}
