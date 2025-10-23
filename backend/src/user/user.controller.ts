import { AuthGuard } from "@backend/core/guard/auth.guard";
import { SetupService } from "@backend/core/setup.service";
import { UserCreationRequest } from "@backend/user/model/api/creation.request.dto";
import { UserCreationResponse } from "@backend/user/model/api/creation.response.dto";
import { UserLoginResponse } from "@backend/user/model/api/login.response.dto";
import { User } from "@backend/user/model/user.model";
import { UserService } from "@backend/user/user.service";
import { BadRequestException, Body, Controller, Get, Logger, NotFoundException, Param, Post } from "@nestjs/common";
import {
  ApiBadRequestResponse,
  ApiBody,
  ApiCreatedResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from "@nestjs/swagger";
import { JWTLoginRequest, UsernamePasswordLoginRequest } from "./model/api/login.request.dto";

/** This controller provides the endpoint for all User related content */
@Controller("user")
@ApiTags("User")
export class UserController {
  private readonly logger = new Logger();

  constructor(
    private readonly userService: UserService,
    private setupService: SetupService,
  ) {}

  @Get(":id")
  @ApiOperation({
    summary: "Get user by ID.",
    description: "Retrieves a user's information by their ID.",
  })
  @ApiOkResponse({ description: "User found successfully.", type: User })
  @ApiNotFoundResponse({ description: "User with the specified ID not found." })
  @AuthGuard.attach()
  async getById(@Param("id") id: string) {
    const user = await User.findOne({ where: { id: id } });
    if (user == null) throw new NotFoundException();
    else return user;
  }

  @Post("login")
  @ApiOperation({
    summary: "Login with username and password.",
    description: "Authenticates a user with their username and password, returning user details and a new JWT for session management.",
  })
  @ApiCreatedResponse({ description: "User login successful.", type: UserLoginResponse })
  @ApiUnauthorizedResponse({ description: "Invalid credentials provided." })
  @ApiBody({ type: UsernamePasswordLoginRequest })
  async login(@Body() userLoginRequest: UsernamePasswordLoginRequest): Promise<UserLoginResponse> {
    return this.userService.login(userLoginRequest);
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
    return this.userService.loginWithJWT(userLoginRequest);
  }

  @Post("create")
  @ApiOperation({
    summary: "Create a new user.",
    description: "Allows for the creation of a new user. Only works during initial setup of the app.",
  })
  @ApiCreatedResponse({ description: "User created successfully.", type: UserCreationResponse })
  @ApiBadRequestResponse({ description: "The app is not in a setup state or invalid input." })
  @ApiBody({ type: UserCreationRequest })
  async create(data: UserCreationRequest) {
    const firstTimeSetupStatus = await this.setupService.firstTimeSetupDetermination();
    if (firstTimeSetupStatus === "welcome") {
      const user = await User.createUser(data.username, data.password, true);
      this.logger.log(`Admin account created with name ${data.username}`);
      return UserCreationResponse.fromPlain({ username: user.username });
    } else throw new BadRequestException("The app is not in a setup state.");
  }
}
