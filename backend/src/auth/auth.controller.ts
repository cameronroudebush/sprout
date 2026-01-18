import { Body, Controller, Post } from "@nestjs/common";
import { ApiBody, ApiCreatedResponse, ApiOperation, ApiTags, ApiUnauthorizedResponse } from "@nestjs/swagger";
import { AuthService } from "./auth.service";
import { JWTLoginRequest, UsernamePasswordLoginRequest } from "./model/api/login.request.dto";
import { UserLoginResponse } from "./model/api/login.response.dto";

/** This controller provides the endpoints for authentication related capabilities. */
@Controller("auth")
@ApiTags("Auth")
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post("login")
  @ApiOperation({
    summary: "Login with username and password.",
    description: "Authenticates a user with their username and password, returning user details and a new JWT for session management.",
  })
  @ApiCreatedResponse({ description: "User login successful.", type: UserLoginResponse })
  @ApiUnauthorizedResponse({ description: "Invalid credentials provided." })
  @ApiBody({ type: UsernamePasswordLoginRequest })
  async login(@Body() userLoginRequest: UsernamePasswordLoginRequest): Promise<UserLoginResponse> {
    return this.authService.login(userLoginRequest);
  }

  @Post("login/jwt")
  @ApiOperation({
    summary: "Login with an existing JWT.",
    description: "Validates an existing JWT. If valid, it returns the user details and the same JWT.",
  })
  @ApiCreatedResponse({ description: "User login successful.", type: UserLoginResponse })
  @ApiUnauthorizedResponse({ description: "The provided JWT is invalid or has expired." })
  @ApiBody({ type: JWTLoginRequest })
  async loginWithJWT(@Body() userLoginRequest: JWTLoginRequest): Promise<UserLoginResponse> {
    return this.authService.loginWithJWT(userLoginRequest);
  }
}
