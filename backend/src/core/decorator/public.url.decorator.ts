import { createParamDecorator, ExecutionContext } from "@nestjs/common";

/**
 * A custom parameter decorator to extract the public URL based on the incoming request
 */
export const PublicURL = createParamDecorator((_data: unknown, ctx: ExecutionContext): string => {
  const request = ctx.switchToHttp().getRequest();

  // Calculate Protocol
  // Trust X-Forwarded-Proto (Traefik/Proxy) -> Fallback to standard protocol
  const protocol = request.headers["x-forwarded-proto"] || request.protocol;

  // Calculate Host
  // Trust X-Forwarded-Host (Traefik/Proxy) -> Fallback to Host header
  const host = request.headers["x-forwarded-host"] || request.get("host");

  return `${protocol}://${host}`;
});
