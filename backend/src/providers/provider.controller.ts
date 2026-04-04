import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { ProviderBase } from "@backend/providers/base/core";
import { ProviderConfig } from "@backend/providers/base/model/provider.config.model";
import { PROVIDER_LIST_TOKEN } from "@backend/providers/model/constants";
import { User } from "@backend/user/model/user.model";
import { Controller, Get, Inject } from "@nestjs/common";
import { ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";

/** This controller provides endpoints for basic provider functionality shared across all providers */
@Controller("provider")
@ApiTags("Provider")
@AuthGuard.attach()
export class BaseProviderController {
  //   private readonly logger = new Logger("provider:controller");
  constructor(@Inject(PROVIDER_LIST_TOKEN) private readonly providers: ProviderBase[]) {}

  @Get("config")
  @ApiOperation({
    summary: "Get provider configuration.",
    description: "Returns the provider configuration so we know what providers are available.",
  })
  @AuthGuard.attach()
  @ApiOkResponse({ description: "The list of available providers and their status.", type: [ProviderConfig] })
  async getConfig(@CurrentUser() user: User) {
    return await Promise.all(
      this.providers.map(async (x) => {
        const config = x.config;
        config.enabled = await x.isAvailable(user);
        return config;
      }),
    );
  }
}
