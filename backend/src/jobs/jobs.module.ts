import { ConfigurationModule } from "@backend/config/config.module";
import { Configuration } from "@backend/config/core";
import { EmailModule } from "@backend/email/email.module";
import { DatabaseBackupJob } from "@backend/jobs/backup";
import { ExchangeRateJob } from "@backend/jobs/exchange-rate";
import { BackgroundJob } from "@backend/jobs/job-base";
import { PendingTransactionJob } from "@backend/jobs/pending.transaction";
import { StatusEmailJob } from "@backend/jobs/status-email";
import { ProviderSyncOrchestratorJob } from "@backend/jobs/sync";
import { SyncNotificationJob } from "@backend/jobs/sync.notification";
import { UserDeviceJob } from "@backend/jobs/user.device";
import { NotificationModule } from "@backend/notification/notification.module";
import { ProviderModule } from "@backend/providers/provider.module";
import { SSEModule } from "@backend/sse/sse.module";
import { TransactionModule } from "@backend/transaction/transaction.module";
import { Module, OnApplicationBootstrap } from "@nestjs/common";
import { ModuleRef } from "@nestjs/core";

@Module({
  imports: [ProviderModule, EmailModule, TransactionModule, NotificationModule, ConfigurationModule, SSEModule],
  controllers: [],
  providers: [ExchangeRateJob, DatabaseBackupJob, PendingTransactionJob, UserDeviceJob, StatusEmailJob, ProviderSyncOrchestratorJob, SyncNotificationJob],
  exports: [ProviderSyncOrchestratorJob],
})
export class JobsModule implements OnApplicationBootstrap {
  constructor(private readonly moduleRef: ModuleRef) {}

  /** Starts the background jobs for all providers of the {@link JobsModule} */
  async onApplicationBootstrap() {
    const providers = Reflect.getMetadata("providers", JobsModule) || [];
    if (!Configuration.isRunningScript)
      await Promise.all(
        providers.map(async (provider: any) => {
          const token = provider.provide || provider;
          const job = this.moduleRef.get<BackgroundJob<any>>(token, { strict: true });
          if (job.start) return await job.start();
          else return Promise.resolve();
        }),
      );
  }
}
