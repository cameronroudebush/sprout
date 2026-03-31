import { Configuration } from "@backend/config/core";
import { ProviderSyncJob } from "@backend/jobs/sync";
import { UserDeviceJob } from "@backend/jobs/user.device";
import { NotificationService } from "@backend/notification/notification.service";
import { ProviderBase } from "@backend/providers/base/core";
import { PROVIDER_LIST_TOKEN } from "@backend/providers/provider.module";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { Inject, Injectable } from "@nestjs/common";
import { DatabaseBackup } from "./backup";
import { PendingTransactionJob } from "./pending.transaction";

/** A central class that starts background job runners */
@Injectable()
export class JobsService {
  constructor(
    private readonly transactionRuleService: TransactionRuleService,
    private readonly notificationService: NotificationService,
    @Inject(PROVIDER_LIST_TOKEN) private readonly providers: ProviderBase[],
  ) {}

  /** A dictionary of registered background jobs */
  jobs: { dbBackup?: DatabaseBackup; pendingTransaction: PendingTransactionJob; userDevice: UserDeviceJob; providerSyncs: ProviderSyncJob[] } = {} as any;

  /** Starts the background jobs */
  async start() {
    if (Configuration.database.backup.enabled) this.jobs.dbBackup = await new DatabaseBackup().start();
    this.jobs.pendingTransaction = await new PendingTransactionJob().start();
    this.jobs.userDevice = await new UserDeviceJob().start();
    this.jobs.providerSyncs = await Promise.all(
      this.providers.map(async (x) => await new ProviderSyncJob(this.transactionRuleService, this.notificationService, x).start()),
    );
  }
}
