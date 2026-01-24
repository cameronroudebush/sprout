import { User } from "@backend/user/model/user.model";
import { createParamDecorator, ExecutionContext } from "@nestjs/common";

/**
 * A custom parameter decorator to extract the current user from the request.
 * The user is attached to the request by the {@link AuthGuard}.
 */
export const CurrentUser = createParamDecorator((_data: unknown, ctx: ExecutionContext): User => {
  const request = ctx.switchToHttp().getRequest();
  if (request.user == null) throw new Error("User must be defined for request");
  return request.user;
});
