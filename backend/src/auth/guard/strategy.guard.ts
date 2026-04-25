import { LocalStrategyName } from "@backend/auth/strategy/local.strategy";
import { OIDCStrategyName } from "@backend/auth/strategy/oidc.strategy";
import { Configuration } from "@backend/config/core";
import { CanActivate, ExecutionContext, ForbiddenException, Injectable, SetMetadata, UseGuards } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { ApiExcludeController, ApiExcludeEndpoint } from "@nestjs/swagger";

/**
 * This guard allows you to restrict your endpoints to only be available
 *  in the event specific strategies are available for authentication
 */
@Injectable()
export class StrategyGuard implements CanActivate {
  static readonly METADATA_KEY = "strategy_method";

  /** Dynamically attaches the strategy guard based on the configuration you give. For more info see {@link StrategyGuard} */
  static attach(method: typeof OIDCStrategyName | typeof LocalStrategyName) {
    return function (target: any, propertyKey?: string | symbol, descriptor?: PropertyDescriptor) {
      SetMetadata(StrategyGuard.METADATA_KEY, method)(target, propertyKey!, descriptor!);
      UseGuards(StrategyGuard)(target, propertyKey!, descriptor!);

      // Conditionally remove from api docs if the strategy is disabled
      if (Configuration.server.auth.type !== method && Configuration.isRunningScript === false) {
        if (descriptor && propertyKey) {
          ApiExcludeEndpoint()(target, propertyKey, descriptor);
        } else {
          ApiExcludeController()(target as Function);
        }
      }
    };
  }

  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredMethod = this.reflector.getAllAndOverride<string>(StrategyGuard.METADATA_KEY, [context.getHandler(), context.getClass()]);
    if (!requiredMethod) return true;

    const activeStrategy = Configuration.server.auth.type;

    if (activeStrategy !== requiredMethod) {
      throw new ForbiddenException(`This endpoint is disabled because the current auth strategy is ${activeStrategy}.`);
    }

    return true;
  }
}
