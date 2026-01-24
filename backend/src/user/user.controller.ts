import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { Category } from "@backend/category/model/category.model";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { SetupService } from "@backend/core/setup.service";
import { NotificationType } from "@backend/notification/model/notification.type";
import { NotificationService } from "@backend/notification/notification.service";
import { UserCreationRequest } from "@backend/user/model/api/creation.request.dto";
import { UserCreationResponse } from "@backend/user/model/api/creation.response.dto";
import { RegisterDeviceDto } from "@backend/user/model/api/register.device.dto";
import { UserDevice } from "@backend/user/model/user.device.model";
import { DevicePlatform } from "@backend/user/model/user.device.type";
import { User } from "@backend/user/model/user.model";
import { BadRequestException, Body, Controller, Get, Logger, NotFoundException, Param, Post } from "@nestjs/common";
import { ApiBadRequestResponse, ApiBody, ApiCreatedResponse, ApiNotFoundResponse, ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";

/** This controller provides the endpoint for all User related content */
@Controller("user")
@ApiTags("User")
export class UserController {
  private readonly logger = new Logger();

  constructor(
    private setupService: SetupService,
    private notificationService: NotificationService,
  ) {}

  @Get("me")
  @ApiOperation({
    summary: "Get's current user info.",
    description: "Returns the current user from the database.",
  })
  @ApiOkResponse({ description: "User found successfully.", type: User })
  @AuthGuard.attach()
  async me(@CurrentUser() user: User) {
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
    summary: "Create a new user.",
    description: "Allows for the creation of a new user. Only works during initial setup of the app.",
  })
  @ApiCreatedResponse({ description: "User created successfully.", type: UserCreationResponse })
  @ApiBadRequestResponse({ description: "The app is not in a setup state or invalid input." })
  @ApiBody({ type: UserCreationRequest })
  async create(@Body() data: UserCreationRequest) {
    const firstTimeSetupStatus = await this.setupService.firstTimeSetupDetermination();
    if (firstTimeSetupStatus === "welcome") {
      try {
        const user = await User.createUser(data.username.toLowerCase(), data.password, true);
        this.logger.log(`Admin account created with name ${data.username}`);
        // Insert some default data
        await Category.insertMany(Category.getDefaultCategoriesForUser(user));
        return UserCreationResponse.fromPlain({ username: user.username });
      } catch (e) {
        throw new BadRequestException((e as Error).message);
      }
    } else throw new BadRequestException("The app is not in a setup state.");
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

  // TODO: Remove
  @Post("notification/test")
  async test() {
    const user = await User.find({});
    for (const device of await UserDevice.find({})) {
      this.notificationService.notifyUser(user[0]!, `Device registered, ${device.id}`, "TEST", NotificationType.info);
    }
  }
}
