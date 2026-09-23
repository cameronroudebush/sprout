import { Configuration } from "@backend/config/core";
import { createParamDecorator, ExecutionContext } from "@nestjs/common";
import { Request } from "express";

/**
 * Utility to resolve the public base URL using configured settings or request headers.
 * Accepts either an Express Request object or a NestJS ExecutionContext.
 */
export function getPublicUrl(context: Request | ExecutionContext): string {
  // Use public URL if configured
  if (Configuration.server.publicUrl?.trim()) {
    return Configuration.server.publicUrl.trim().replace(/\/$/, "");
  }
  // Return the URL from the request otherwise to allow easy deployment
  const req: any =
    typeof (context as ExecutionContext).switchToHttp === "function" ? (context as ExecutionContext).switchToHttp().getRequest() : (context as Request);
  const protocol = (req.headers["x-forwarded-proto"] as string) || req.protocol;
  const host = (req.headers["x-forwarded-host"] as string) || req.get("host");
  return `${protocol}://${host}`;
}

/**
 * A custom parameter decorator to extract the public URL based on the incoming request
 */
export const PublicURL = createParamDecorator((_data: unknown, ctx: ExecutionContext): string => {
  return getPublicUrl(ctx);
});
