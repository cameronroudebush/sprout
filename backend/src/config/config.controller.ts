import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { Configuration } from "@backend/config/core";
import { APIConfig, TileConfig } from "@backend/config/model/api/configuration.dto";
import { UnsecureAppConfiguration } from "@backend/config/model/api/unsecure.app.config.dto";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { DemoDataService } from "@backend/demo/demo.data.service";
import { User } from "@backend/user/model/user.model";
import { UserService } from "@backend/user/user.service";
import { Controller, Get } from "@nestjs/common";
import { ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";

/** This class provides endpoints for getting the current configuration of the backend. */
@Controller("config")
@ApiTags("Config")
export class ConfigController {
  constructor(private readonly userService: UserService) {}

  @Get()
  @ApiOperation({
    summary: "Get app configuration.",
    description: "Returns the app configuration for the frontend to be able to reference.",
  })
  @AuthGuard.attach()
  @ApiOkResponse({ description: "The configuration that external services may want to know about.", type: APIConfig })
  async get(@CurrentUser() _user: User) {
    return new APIConfig(
      Configuration.server.prompt.hasChatKey,
      Configuration.server.email.enabled,
      new TileConfig(Configuration.server.lightModeTiles, Configuration.server.darkModeTiles),
      Configuration.server.brandFetch.clientId,
    );
  }

  @Get("unsecure")
  @ApiOperation({
    summary: "Get unsecure app configuration.",
    description:
      "Returns the unsecure app configuration. This won't contain any sensitive information but gives required metadata for the app to properly configure itself.",
  })
  @ApiOkResponse({ description: "Unsecure app configuration obtained successfully.", type: UnsecureAppConfiguration })
  async getUnsecure() {
    const demoCredentials = Configuration.isDemoMode ? DemoDataService.credentials : undefined;
    return new UnsecureAppConfiguration(Configuration.version, Configuration.server.auth.type, await this.userService.allowUserCreation(), demoCredentials);
  }
}
