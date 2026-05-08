import { StrategyGuard } from "@backend/auth/guard/strategy.guard";
import { User } from "@backend/user/model/user.model";
import { Body, Controller, Post, Req, Res } from "@nestjs/common";
import { ApiBody, ApiCreatedResponse, ApiOperation, ApiTags, ApiUnauthorizedResponse } from "@nestjs/swagger";
import { Request, Response } from "express";
import { AuthService } from "./auth.service";
import { UsernamePasswordLoginRequest } from "./model/api/login.request.dto";

/** This controller provides the endpoints for authentication related capabilities. */
@Controller("auth")
@ApiTags("Auth")
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post("login")
  @ApiOperation({
    summary: "Login with username and password.",
    description: "Authenticates a user with their username and password, returning user details. Only available on local strategy auth.",
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

  @Post("logout")
  @ApiOperation({ summary: "Logout the user", description: "Clears the session cookies any authentication that has happened." })
  async logout(@Res({ passthrough: true }) res: Response) {
    this.authService.clearAllCookieTokens(res);
    return { success: true };
  }
}
