import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { CustomTypes } from "@backend/core/model/utility/custom.types";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { UserConfig } from "@backend/user/model/user.config.model";
import { User } from "@backend/user/model/user.model";
import { UserService } from "@backend/user/user.service";
import { Body, Controller, Get, NotFoundException, Patch } from "@nestjs/common";
import { ApiBody, ApiNotFoundResponse, ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";
import { isEqual } from "lodash";

/** This controller provides the endpoint for all User configuration related content */
@Controller("user-config")
@ApiTags("User Config")
@AuthGuard.attach()
export class UserConfigController {
  constructor(
    private readonly userService: UserService,
    private readonly sseService: SSEService,
  ) {}

  @Get()
  @ApiOperation({
    summary: "Get user config.",
    description: "Retrieves the current user's configuration.",
  })
  @ApiOkResponse({ description: "User config found successfully.", type: UserConfig })
  @ApiNotFoundResponse({ description: "User couldn't be found." })
  async get(@CurrentUser() user: User) {
    const dbUser = await User.findOne({ where: { id: user.id } });
    if (dbUser == null)
      throw new NotFoundException(); // This shouldn't be possible
    else return dbUser.config;
  }

  @Patch()
  @ApiOperation({
    summary: "Edit user config.",
    description: "Edits the current users configuration.",
  })
  @ApiOkResponse({ description: "User configuration updated successfully.", type: UserConfig })
  @ApiNotFoundResponse({ description: "User configuration couldn't be found." })
  @ApiBody({ type: UserConfig })
  async edit(@CurrentUser() user: User, @Body() conf: UserConfig) {
    const existingConfig = await UserConfig.findOne({ where: { user: { id: user.id } } });
    if (existingConfig == null) throw new NotFoundException(); // This shouldn't be possible
    const userConfig = UserConfig.fromPlain(conf);
    userConfig.id = existingConfig.id;
    await this.userService.syncEncryptedFields(userConfig, existingConfig);

    // Force a re-sync if any of the following properties are not the same
    const properties: Array<CustomTypes.PropertyNames<UserConfig, any>> = ["currency"];
    const shouldForceUpdate = properties.find((x) => !isEqual(conf[x], existingConfig[x])) != null;
    if (shouldForceUpdate) this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);

    return await userConfig.update();
  }
}
