import { UserLoginResponse } from "@backend/user/model/api/login.response";
import { UserService } from "@backend/user/user.service";
import { Body, Controller, Post } from "@nestjs/common";
import { ApiBody, ApiOkResponse, ApiOperation, ApiTags, ApiUnauthorizedResponse } from "@nestjs/swagger";
import { JWTLoginRequest, UsernamePasswordLoginRequest } from "./model/api/login.request";

/** This controller provides the endpoint for all User related content */
@Controller("user")
@ApiTags("User")
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Post("login")
  @ApiOperation({
    summary: "Login with username and password",
    description: "Authenticates a user with their username and password, returning user details and a new JWT for session management.",
  })
  @ApiOkResponse({ description: "User login successful", type: UserLoginResponse })
  @ApiUnauthorizedResponse({ description: "Invalid credentials provided." })
  @ApiBody({ type: UsernamePasswordLoginRequest })
  async login(@Body() userLoginRequest: UsernamePasswordLoginRequest): Promise<UserLoginResponse> {
    return this.userService.login(userLoginRequest);
  }

  @Post("login/jwt")
  @ApiOperation({
    summary: "Login with an existing JWT",
    description: "Validates an existing JWT. If valid, it returns the user details and the same JWT, effectively refreshing the user's session state.",
  })
  @ApiOkResponse({ description: "User login successful", type: UserLoginResponse })
  @ApiUnauthorizedResponse({ description: "The provided JWT is invalid or has expired." })
  @ApiBody({ type: JWTLoginRequest })
  async loginWithJWT(@Body() userLoginRequest: JWTLoginRequest): Promise<UserLoginResponse> {
    return this.userService.loginWithJWT(userLoginRequest);
  }
}
