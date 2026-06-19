import { Configuration } from "@backend/config/core";
import { BadRequestException, CanActivate, ExecutionContext, Injectable, NotFoundException, UseGuards } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { ApiExcludeController, ApiExcludeEndpoint } from "@nestjs/swagger";

const IS_ENABLED_KEY = "config:guard:enabled";

/** Options that we store in the reflector for the usage of this controller */
export interface RestrictionOptions {
  /** The condition determining if this route/controller should be locked down */
  isEnabled: boolean;
  /** The HTTP exception to throw when restricted. Defaults to 'NotFound' (404) */
  errorType?: "NotFound" | "BadRequest";
  /** If true, the route will be hidden from OpenAPI docs when restricted. Defaults to true. */
  hideFromDocs?: boolean;
  /** A message to supply to the error type. Only works for certain error types. */
  message?: string;
}

/** A guard that when applied to an endpoint can disable it based on the enabled state */
@Injectable()
export class EnabledGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  /**
   * Shorthand helper to protect data-mutating routes in a demo environment.
   * When `Configuration.isDemoMode` is active, it automatically returns an HTTP 403 (Forbidden),
   * while keeping the endpoints visible in the Swagger OpenAPI documentation so potential users can still review the API design.
   */
  static attachDemoMode() {
    return this.attach(!Configuration.isDemoMode, {
      errorType: "BadRequest",
      hideFromDocs: false,
      message: "This action is not allowed while the app is in demo mode.",
    });
  }

  /**
   * Dynamically attaches the enabled guard and conditionally hides the endpoint from openAPI.
   * @param isEnabled Pass true to make it executable, false to 404.
   */
  static attach(isEnabled: boolean, options?: Omit<RestrictionOptions, "isEnabled">) {
    return function (target: any, propertyKey?: string | symbol, descriptor?: PropertyDescriptor) {
      const targetValue = descriptor && propertyKey ? descriptor.value : target;
      Reflect.defineMetadata(IS_ENABLED_KEY, { ...options, isEnabled }, targetValue);
      UseGuards(EnabledGuard)(target, propertyKey!, descriptor!);

      const hideFromDocs = options?.hideFromDocs ?? true;
      if (!isEnabled && hideFromDocs && !Configuration.isDevBuild && Configuration.isRunningScript === false) {
        if (descriptor && propertyKey) ApiExcludeEndpoint()(target, propertyKey, descriptor);
        else ApiExcludeController()(target as Function);
      }
    };
  }

  canActivate(context: ExecutionContext): boolean {
    const options = this.reflector.getAllAndOverride<RestrictionOptions>(IS_ENABLED_KEY, [context.getHandler(), context.getClass()]);
    // If no restriction configuration is present or the restriction condition evaluates to false, let it pass
    if (!options || options.isEnabled) return true;

    // Determine appropriate error semantic
    if (options.errorType === "BadRequest") throw new BadRequestException(options.message ?? "This action is not allowed in the current application state.");
    else throw new NotFoundException();
  }
}
