import { User } from "@backend/user/model/user.model";
import { CanActivate, ExecutionContext, Injectable, UnauthorizedException, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiUnauthorizedResponse } from "@nestjs/swagger";

@Injectable()
export class AuthGuard implements CanActivate {
  /** Dynamically attaches the expected guards and response indication for our authentication to endpoints */
  static attach() {
    return function <TFunction extends Function>(target: Object, propertyKey?: string | symbol, descriptor?: TypedPropertyDescriptor<TFunction>) {
      ApiUnauthorizedResponse({ description: "Authentication is required." })(target, propertyKey!, descriptor!);
      ApiBearerAuth()(target, propertyKey!, descriptor!);
      UseGuards(AuthGuard)(target, propertyKey!, descriptor!);
    };
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const authorization = request.headers.authorization;
    if (authorization == null || !authorization.includes("Bearer")) throw new UnauthorizedException("Malformed or excluded Bearer token.");

    try {
      const cleanJWT = authorization.replace("Bearer ", "");
      const jwtResult = User.verifyJWT(cleanJWT);
      const user = await User.findOne({ where: { username: jwtResult.username } });
      if (!user) throw new UnauthorizedException("User could not be found.");
      /** Attach the user object to the request so {@link current-user.decorator.ts} can use it */
      request.user = user;
      return true;
    } catch (e) {
      throw new UnauthorizedException("Invalid or expired token.");
    }
  }
}
