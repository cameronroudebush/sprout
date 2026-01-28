import { Configuration } from "@backend/config/core";
import { ProviderSyncJob } from "@backend/jobs/sync";
import { UserDeviceJob } from "@backend/jobs/user.device";
import { NotificationService } from "@backend/notification/notification.service";
import { ProviderService } from "@backend/providers/provider.service";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { Injectable } from "@nestjs/common";
import { DatabaseBackup } from "./backup";
import { PendingTransactionJob } from "./pending.transaction";

/** A central class that starts background job runners */
@Injectable()
export class JobsService {
  constructor(
    private readonly providerService: ProviderService,
    private readonly transactionRuleService: TransactionRuleService,
    private readonly notificationService: NotificationService,
  ) {}

  /** A dictionary of registered background jobs */
  jobs: { dbBackup?: DatabaseBackup; pendingTransaction: PendingTransactionJob; userDevice: UserDeviceJob; providerSync: ProviderSyncJob } = {} as any;

  /** Starts the background jobs */
  async start() {
    if (Configuration.database.backup.enabled) this.jobs.dbBackup = await new DatabaseBackup().start();
    this.jobs.pendingTransaction = await new PendingTransactionJob().start();
    this.jobs.userDevice = await new UserDeviceJob().start();
    this.jobs.providerSync = await new ProviderSyncJob(this.providerService, this.transactionRuleService, this.notificationService).start();
  }
}
