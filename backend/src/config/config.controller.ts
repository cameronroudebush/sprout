import { Configuration } from "@backend/config/core";
import { APIConfig } from "@backend/config/model/api/configuration.dto";
import { UnsecureAppConfiguration } from "@backend/config/model/api/unsecure.app.config.dto";
import { AuthGuard } from "@backend/core/guard/auth.guard";
import { SetupService } from "@backend/core/setup.service";
import { Sync } from "@backend/jobs/model/sync.model";
import { ProviderService } from "@backend/providers/provider.service";
import { Controller, Get } from "@nestjs/common";
import { ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";

/** This class provides endpoints for getting the current configuration of the backend. */
@Controller("config")
@ApiTags("Config")
export class ConfigController {
  constructor(
    private readonly providerService: ProviderService,
    private readonly setupService: SetupService,
  ) {}

  @Get()
  @ApiOperation({
    summary: "Get app configuration.",
    description: "Returns the app configuration for the frontend to be able to reference.",
  })
  @AuthGuard.attach()
  @ApiOkResponse({ description: "The configuration that external services may want to know about.", type: APIConfig })
  async get() {
    const lastSync = (await Sync.find({ order: { time: "DESC" } }))[0];
    const providers = this.providerService.getAll();
    return new APIConfig(
      lastSync,
      providers.map((x) => x.config),
    );
  }

  @Get("unsecure")
  @ApiOperation({
    summary: "Get unsecure app configuration.",
    description: "Returns the unsecure app configuration. This won't contain any sensitive information but tells endpoints if the first time setup needs ran.",
  })
  @ApiOkResponse({ description: "Unsecure app configuration obtained successfully.", type: UnsecureAppConfiguration })
  async getUnsecure() {
    return UnsecureAppConfiguration.fromPlain({
      firstTimeSetupPosition: await this.setupService.firstTimeSetupDetermination(),
      version: Configuration.version,
    });
  }
}
