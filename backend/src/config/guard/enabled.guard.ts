import { Configuration } from "@backend/config/core";
import { CanActivate, ExecutionContext, Injectable, NotFoundException, UseGuards } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { ApiExcludeController, ApiExcludeEndpoint } from "@nestjs/swagger";

const IS_ENABLED_KEY = "config:guard:enabled";

/** A guard that when applied to an endpoint can disable it based on the enabled state */
@Injectable()
export class EnabledGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  /**
   * Dynamically attaches the enabled guard and conditionally hides the endpoint from openAPI.
   * @param isEnabled Pass true to make it executable, false to 404.
   */
  static attach(isEnabled: boolean) {
    return function (target: any, propertyKey?: string | symbol, descriptor?: PropertyDescriptor) {
      if (descriptor && propertyKey) {
        Reflect.defineMetadata(IS_ENABLED_KEY, isEnabled, descriptor.value);
      } else {
        Reflect.defineMetadata(IS_ENABLED_KEY, isEnabled, target);
      }

      UseGuards(EnabledGuard)(target, propertyKey!, descriptor!);
      // Conditionally remove from api docs if disabled
      if (!Configuration.isDevBuild && Configuration.isRunningScript === false) {
        if (descriptor && propertyKey) {
          ApiExcludeEndpoint()(target, propertyKey, descriptor);
        } else {
          ApiExcludeController()(target as Function);
        }
      }
    };
  }

  canActivate(context: ExecutionContext): boolean {
    const isEnabled = this.reflector.getAllAndOverride<boolean>(IS_ENABLED_KEY, [context.getHandler(), context.getClass()]);
    // If explicit false is passed, throw 404
    if (isEnabled === false) throw new NotFoundException();
    return true;
  }
}
