import { User } from "@backend/user/model/user.model";
import { applyDecorators, CanActivate, ExecutionContext, ForbiddenException, Injectable, UseGuards } from "@nestjs/common";
import { ApiForbiddenResponse } from "@nestjs/swagger";
import { AuthGuard } from "./auth.guard";

@Injectable()
export class AdminGuard implements CanActivate {
  /**
   * Static helper to require both authentication AND admin privileges.
   * Usage: @AdminGuard.attach()
   */
  static attach() {
    return applyDecorators(AuthGuard.attach(), ApiForbiddenResponse({ description: "Admin privileges required." }), UseGuards(AdminGuard));
  }

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    // Verify user exists and user.admin is true
    if (user && user instanceof User && user.admin === true) return true;
    throw new ForbiddenException("You do not have administrative privileges to access this resource.");
  }
}
