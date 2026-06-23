import { Configuration } from "@backend/config/core";
import { createParamDecorator, ExecutionContext } from "@nestjs/common";

/**
 * A custom parameter decorator to extract the public URL based on the incoming request
 */
export const PublicURL = createParamDecorator((_data: unknown, ctx: ExecutionContext): string => {
  // Use public URL if configured
  if (Configuration.server.publicUrl?.trim()) return Configuration.server.publicUrl.trim().replace(/\/$/, "");
  // Return the URL from the request otherwise to allow easy deployment
  const request = ctx.switchToHttp().getRequest();
  const protocol = request.headers["x-forwarded-proto"] || request.protocol;
  const host = request.headers["x-forwarded-host"] || request.get("host");
  return `${protocol}://${host}`;
});
