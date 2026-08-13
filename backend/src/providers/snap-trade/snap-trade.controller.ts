import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { Configuration } from "@backend/config/core";
import { EnabledGuard } from "@backend/config/guard/enabled.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { SnapTradeProviderService } from "@backend/providers/snap-trade/snap-trade.provider.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { Controller, Post, Query } from "@nestjs/common";
import { ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";

@Controller("provider/snap-trade")
@ApiTags("Provider")
@AuthGuard.attach()
@EnabledGuard.attach(Configuration.providers.snapTrade.enabled)
export class SnapTradeProviderController {
  constructor(
    private readonly snapTradeProviderService: SnapTradeProviderService,
    private readonly sseService: SSEService,
  ) {}

  @Post("link")
  @ApiOperation({
    summary: "Generate a connection link.",
    description: "Registers the user with SnapTrade if needed and generates a redirect URL to connect a brokerage.",
  })
  @ApiOkResponse({ description: "Link generated successfully.", type: String })
  @EnabledGuard.attachDemoMode()
  async generateLink(@CurrentUser() user: User, @Query("redirectUrl") redirectUrl?: string) {
    return await this.snapTradeProviderService.generateLinkToken(user, { redirectUrl });
  }

  @Post("post-link")
  @ApiOperation({ summary: "Fires actions to perform once a user has linked new accounts." })
  @EnabledGuard.attachDemoMode()
  async postLink(@CurrentUser() user: User) {
    await this.snapTradeProviderService.exchangeAndCreateAccounts(user);
    this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);
  }
}
