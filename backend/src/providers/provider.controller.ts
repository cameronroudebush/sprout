import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { EnabledGuard } from "@backend/config/guard/enabled.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { ProviderBase } from "@backend/providers/base/core";
import { ProviderConfig } from "@backend/providers/base/model/provider.config.model";
import { PROVIDER_LIST_TOKEN } from "@backend/providers/model/constants";
import { ManualSyncDto } from "@backend/providers/model/manual.sync.dto";
import { Sync } from "@backend/providers/model/sync.model";
import { ProviderService } from "@backend/providers/provider.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { Body, Controller, Get, Inject, InternalServerErrorException, Put } from "@nestjs/common";
import { ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";
import { startOfDay } from "date-fns";
import { cloneDeep } from "lodash";
import { MoreThanOrEqual } from "typeorm";

/** This controller provides endpoints for basic provider functionality shared across all providers */
@Controller("provider")
@ApiTags("Provider")
@AuthGuard.attach()
export class BaseProviderController {
  //   private readonly logger = new Logger("provider:controller");

  constructor(
    private readonly sseService: SSEService,
    private readonly providerService: ProviderService,
    @Inject(PROVIDER_LIST_TOKEN) private readonly providers: ProviderBase[],
  ) {}

  @Get("config")
  @ApiOperation({
    summary: "Get provider configuration.",
    description: "Returns the provider configuration so we know what providers are available.",
  })
  @ApiOkResponse({ description: "The list of available providers and their status.", type: [ProviderConfig] })
  async getConfig(@CurrentUser() user: User) {
    return await Promise.all(
      this.providers
        .filter((x) => x.getAppConfiguration().enabled)
        .map(async (x) => {
          const config = cloneDeep(x.config);
          config.enabled = await x.isAvailable(user);
          return config;
        }),
    );
  }

  @Put("sync")
  @ApiOperation({
    summary: "Run a manual sync.",
    description: "Runs a manual sync to update specified provider accounts or all connected providers.",
  })
  @ApiOkResponse({ description: "Manual sync completed successfully." })
  @EnabledGuard.attachDemoMode()
  async manualSync(@CurrentUser() user: User, @Body() dto: ManualSyncDto = new ManualSyncDto()) {
    const { force = false, providers } = dto;
    const runningSync = await Sync.findOne({
      where: {
        status: "in-progress",
        time: MoreThanOrEqual(startOfDay(new Date())),
      },
    });
    if (runningSync && !force) throw new InternalServerErrorException("A sync is already in progress. Please wait for it to complete.");
    let syncs: Sync[] = [];
    // If providers is omitted (undefined) or empty, sync everything
    if (!providers || providers.length === 0) {
      const syncResults = await this.providerService.syncUserProviders(user, false);
      syncs = syncResults.filter((x): x is Sync => Boolean(x));
    } else {
      // Otherwise, iterate through the specific requested providers
      const syncResults = await Promise.all(providers.map((providerType) => this.providerService.syncUserProviders(user, false, providerType)));
      syncs = syncResults.filter((x): x is Sync => Boolean(x));
    }
    // Inform of the completed sync
    this.sseService.sendToUser(user, SSEEventType.SYNC);
    // Tell to re-request data if we had any success
    const hasSuccess = syncs.find((x) => x.status !== "failed");
    if (hasSuccess) this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);
  }
}
