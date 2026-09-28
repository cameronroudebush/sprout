import { ConfigurationModule } from "@backend/config/config.module";
import { CoreController } from "@backend/core/core.controller";
import { CoreService } from "@backend/core/core.service";
import { DatabaseBackupJob } from "@backend/core/jobs/backup";
import { ExchangeRateJob } from "@backend/core/jobs/exchange-rate";
import { SproutLogger } from "@backend/core/logger";
import { JobExplorerService } from "@backend/core/services/job.explorer.service";
import { ProviderModule } from "@backend/providers/provider.module";
import { Module } from "@nestjs/common";
import { DiscoveryModule } from "@nestjs/core";

@Module({
  imports: [DiscoveryModule, ConfigurationModule, ProviderModule],
  controllers: [CoreController],
  providers: [CoreService, SproutLogger, JobExplorerService, DatabaseBackupJob, ExchangeRateJob],
  exports: [SproutLogger, JobExplorerService],
})
export class CoreModule {}
