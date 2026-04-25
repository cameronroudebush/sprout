import { Configuration } from "@backend/config/core";
import { CanActivate, Injectable, NotFoundException, UseGuards } from "@nestjs/common";
import { ApiExcludeController, ApiExcludeEndpoint } from "@nestjs/swagger";

/** A guard that when applied to an endpoint disables it's ability from showing up if we're not in dev mode */
@Injectable()
export class DevModeGuard implements CanActivate {
  /** Dynamically attaches the dev mode guard and uses it to hide endpoints based on configuration mode. */
  static attach() {
    return function (target: any, propertyKey?: string | symbol, descriptor?: PropertyDescriptor) {
      UseGuards(DevModeGuard)(target, propertyKey!, descriptor!);

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

  canActivate(): boolean {
    if (Configuration.isDevBuild) return true;
    throw new NotFoundException();
  }
}
