import { ConfigurationModule } from "@backend/config/config.module";
import { CoreController } from "@backend/core/core.controller";
import { DatabaseBackupJob } from "@backend/core/jobs/backup";
import { ExchangeRateJob } from "@backend/core/jobs/exchange-rate";
import { SproutLogger } from "@backend/core/logger";
import { JobExplorerService } from "@backend/core/services/job.explorer.service";
import { Module } from "@nestjs/common";
import { DiscoveryModule } from "@nestjs/core";

@Module({
  imports: [DiscoveryModule, ConfigurationModule],
  controllers: [CoreController],
  providers: [SproutLogger, JobExplorerService, DatabaseBackupJob, ExchangeRateJob],
  exports: [SproutLogger, JobExplorerService],
})
export class CoreModule {}
