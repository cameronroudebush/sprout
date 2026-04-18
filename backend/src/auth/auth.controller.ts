import { StrategyGuard } from "@backend/auth/guard/strategy.guard";
import { extractJwtFromHeaderOrCookie } from "@backend/auth/strategy/auth.extractor";
import { User } from "@backend/user/model/user.model";
import { Body, Controller, Post, Req, Res, UnauthorizedException } from "@nestjs/common";
import { ApiBody, ApiCreatedResponse, ApiOperation, ApiTags, ApiUnauthorizedResponse } from "@nestjs/swagger";
import { Request, Response } from "express";
import { AuthService } from "./auth.service";
import { JWTLoginRequest, UsernamePasswordLoginRequest } from "./model/api/login.request.dto";

/** This controller provides the endpoints for authentication related capabilities. */
@Controller("auth")
@ApiTags("Auth")
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post("login")
  @ApiOperation({
    summary: "Login with username and password.",
    description:
      "Authenticates a user with their username and password, returning user details and a new JWT for requests. Only available on local strategy auth.",
  })
  @ApiCreatedResponse({ description: "User login successful.", type: User })
  @ApiUnauthorizedResponse({ description: "Invalid credentials provided." })
  @ApiBody({ type: UsernamePasswordLoginRequest })
  @StrategyGuard.attach("local")
  async login(@Body() body: UsernamePasswordLoginRequest, @Res({ passthrough: true }) res: Response, @Req() _req: Request) {
    const { user, jwt } = await this.authService.login(body);
    this.authService.setCookieTokens(res, jwt);
    return user;
  }

  @Post("login/jwt")
  @ApiOperation({
    summary: "Login with an existing JWT.",
    description: "Validates an existing JWT. If valid, it returns the user details and the same JWT. Only available on local strategy auth.",
  })
  @ApiCreatedResponse({ description: "User login successful.", type: User })
  @ApiUnauthorizedResponse({ description: "The provided JWT is invalid or has expired." })
  @ApiBody({ type: JWTLoginRequest })
  @StrategyGuard.attach("local")
  async loginWithJWT(@Body() body: JWTLoginRequest, @Req() req: Request, @Res({ passthrough: true }) res: Response) {
    const token = extractJwtFromHeaderOrCookie(req) || body.jwt;
    if (token == null) throw new UnauthorizedException();
    const { user, jwt } = await this.authService.loginWithJWT(token);
    this.authService.setCookieTokens(res, jwt);
    return user;
  }

  @Post("logout")
  @ApiOperation({ summary: "Logout the user", description: "Clears the session cookies any authentication that has happened." })
  async logout(@Res({ passthrough: true }) res: Response) {
    this.authService.clearAllCookieTokens(res);
    return { success: true };
  }
}
