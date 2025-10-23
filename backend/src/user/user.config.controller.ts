import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { AuthGuard } from "@backend/core/guard/auth.guard";
import { UserConfig } from "@backend/user/model/user.config.model";
import { User } from "@backend/user/model/user.model";
import { Body, Controller, Get, NotFoundException, Patch } from "@nestjs/common";
import { ApiBody, ApiNotFoundResponse, ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";

/** This controller provides the endpoint for all User configuration related content */
@Controller("user-config")
@ApiTags("User Config")
@AuthGuard.attach()
export class UserConfigController {
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
    const existingConfig = await UserConfig.findOne({ where: { id: user.config.id } });
    if (existingConfig == null) throw new NotFoundException(); // This shouldn't be possible
    const userConfig = UserConfig.fromPlain(conf);
    userConfig.id = existingConfig.id;
    return await userConfig.update();
  }
}
