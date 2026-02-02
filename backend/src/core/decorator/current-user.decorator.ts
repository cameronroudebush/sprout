import { User } from "@backend/user/model/user.model";
import { createParamDecorator, ExecutionContext, InternalServerErrorException } from "@nestjs/common";

/**
 * A custom parameter decorator to extract the current user from the request.
 * The user is attached to the request by the {@link AuthGuard}.
 * @param allowFailure - If true, returns null instead of throwing when no user is present.
 */
export const CurrentUser = createParamDecorator((allowFailure: boolean = false, ctx: ExecutionContext): User | null => {
  const request = ctx.switchToHttp().getRequest();
  // If user exists, return it immediately
  if (request.user) return request.user;
  // If user is missing but failure is allowed, return null
  if (allowFailure) return null;
  // Default behavior: Strict enforcement
  throw new InternalServerErrorException("User must be defined for request");
});
