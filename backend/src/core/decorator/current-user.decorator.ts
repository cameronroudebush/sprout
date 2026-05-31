import { User } from "@backend/user/model/user.model";
import { createParamDecorator, ExecutionContext, InternalServerErrorException } from "@nestjs/common";

/**
 * A custom parameter decorator to extract the current user from the request.
 * The user is attached to the request by the {@link AuthGuard}.
 * @param allowFailure - If true, returns null instead of throwing when no user is present.
 */
export const CurrentUser = createParamDecorator((allowFailure: boolean = false, ctx: ExecutionContext): User | null => {
  const request = ctx.switchToHttp().getRequest();
  if (request.user) return request.user;
  if (allowFailure) return null;
  throw new InternalServerErrorException("User must be defined for request");
});
