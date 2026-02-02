import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { Configuration } from "@backend/config/core";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { UserCreationRequest } from "@backend/user/model/api/creation.request.dto";
import { UserCreationResponse } from "@backend/user/model/api/creation.response.dto";
import { RegisterDeviceDto } from "@backend/user/model/api/register.device.dto";
import { UserDevice } from "@backend/user/model/user.device.model";
import { DevicePlatform } from "@backend/user/model/user.device.type";
import { User } from "@backend/user/model/user.model";
import { UserSetupContext } from "@backend/user/model/user.setup.context.model";
import { UserService } from "@backend/user/user.service";
import { BadRequestException, Body, Controller, Get, Logger, NotFoundException, Param, Post, Req, UnauthorizedException } from "@nestjs/common";
import { ApiBadRequestResponse, ApiCreatedResponse, ApiNotFoundResponse, ApiOkResponse, ApiOperation, ApiTags, ApiUnauthorizedResponse } from "@nestjs/swagger";

/** This controller provides the endpoint for all User related content */
@Controller("user")
@ApiTags("User")
export class UserController {
  private readonly logger = new Logger("controller:user");

  constructor(private readonly userService: UserService) {}

  @Get("me")
  @ApiOperation({
    summary: "Get's current user info.",
    description: "Returns the current user from the database.",
  })
  @ApiOkResponse({ description: "User found successfully.", type: User })
  @ApiUnauthorizedResponse({ description: "Authentication was given but it was invalid." })
  @ApiNotFoundResponse({ description: "Authentication was given that was found to be valid but no valid user was found." })
  @AuthGuard.attachOptional()
  async me(@CurrentUser(true) user: User, @Req() req: Request) {
    const authConfig = Configuration.server.auth;
    const allowNewUsers = await this.userService.allowUserCreation();
    // No user? Check setup status
    if (user == null) {
      // Check for oidc strategy. 404's will trigger the frontend to allow a new user to be created.
      if (authConfig.type === "oidc" && allowNewUsers) {
        const setup = (req as any).setupUser as UserSetupContext | undefined;
        // No setup user? That means we didn't make it through user validation via the auth guard
        if (setup == null) throw new UnauthorizedException();
        else throw new NotFoundException(); // We do have setup info? Then go ahead and create a new one
      }
      // Check for local strategy. If we don't have any users, safe to assume this is first time setup.
      else if (authConfig.type === "local" && allowNewUsers) throw new NotFoundException();
      else if (user == null) throw new UnauthorizedException(); // Else this isn't a setup request. Hit em with an unauthorized
    }
    // Oh, we do have a user. Go ahead and return it then
    return await User.findOne({ where: { id: user.id } });
  }

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

  @Post("create")
  @ApiOperation({
    summary: "Create a new user..",
    description: "Allows for user creation based on either first time setup configuration or OIDC user config.",
  })
  @ApiCreatedResponse({ description: "User created successfully.", type: UserCreationResponse })
  @ApiBadRequestResponse({ description: "New users are not allowed to be created." })
  @AuthGuard.attachOptional()
  async create(@Body() data: UserCreationRequest, @Req() req: Request) {
    if (!(await this.userService.allowUserCreation())) throw new BadRequestException("New users are not permitted.");
    else {
      try {
        const isFirstUser = (await User.count()) === 0;
        let response: UserCreationResponse;
        if (Configuration.server.auth.type === "oidc") {
          const setup = (req as any).setupUser;
          response = await User.createUser({ ...setup, admin: isFirstUser });
        } else response = await User.createUser({ username: data.username, password: data.password, admin: isFirstUser });
        this.logger.log(`New user registered: ${response.username}${isFirstUser ? ". This is the first user and will be registered as Admin." : ""}`);
        return response;
      } catch (e) {
        throw new BadRequestException((e as Error).message);
      }
    }
  }

  @Post("device/register")
  @ApiOperation({
    summary: "Register a device to a user.",
    description: "Registers a device to the current authenticated user so we can reference it in notification handlers.",
  })
  @ApiOkResponse({ description: "Device registered" })
  @AuthGuard.attach()
  async registerDevice(@CurrentUser() user: User, @Body() data: RegisterDeviceDto) {
    // Check if this specific token is already registered
    let device = await UserDevice.findOne({ where: { fcmToken: data.token } });

    if (device) {
      // Update existing device info
      device.deviceName = data.deviceName ?? device.deviceName;
      device.lastSeenAt = new Date();
      device.user = user; // Re-associate in case the user switched accounts
      device = await device.update();
    } else {
      // Create a new device entry
      device = await new UserDevice(user, data.token, data.platform ?? DevicePlatform.ANDROID, data.deviceName).insert();
    }

    return { success: true, deviceId: device.id };
  }
}
