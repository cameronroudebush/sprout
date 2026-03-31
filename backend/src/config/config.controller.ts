import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { Configuration } from "@backend/config/core";
import { APIConfig } from "@backend/config/model/api/configuration.dto";
import { UnsecureAppConfiguration } from "@backend/config/model/api/unsecure.app.config.dto";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { ProviderBase } from "@backend/providers/base/core";
import { PROVIDER_LIST_TOKEN } from "@backend/providers/provider.module";
import { User } from "@backend/user/model/user.model";
import { UserService } from "@backend/user/user.service";
import { Controller, Get, Inject } from "@nestjs/common";
import { ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";

/** This class provides endpoints for getting the current configuration of the backend. */
@Controller("config")
@ApiTags("Config")
export class ConfigController {
  constructor(
    private readonly userService: UserService,
    @Inject(PROVIDER_LIST_TOKEN) private readonly providers: ProviderBase[],
  ) {}

  @Get()
  @ApiOperation({
    summary: "Get app configuration.",
    description: "Returns the app configuration for the frontend to be able to reference.",
  })
  @AuthGuard.attach()
  @ApiOkResponse({ description: "The configuration that external services may want to know about.", type: APIConfig })
  async get(@CurrentUser() _user: User) {
    return new APIConfig(
      this.providers.map((x) => x.config),
      Configuration.server.prompt.hasChatKey,
    );
  }

  @Get("unsecure")
  @ApiOperation({
    summary: "Get unsecure app configuration.",
    description: "Returns the unsecure app configuration. This won't contain any sensitive information but tells endpoints if the first time setup needs ran.",
  })
  @ApiOkResponse({ description: "Unsecure app configuration obtained successfully.", type: UnsecureAppConfiguration })
  async getUnsecure() {
    return new UnsecureAppConfiguration(Configuration.version, Configuration.server.auth.type, await this.userService.allowUserCreation());
  }
}
