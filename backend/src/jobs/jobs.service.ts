import { Configuration } from "@backend/config/core";
import { ProviderSyncJob } from "@backend/jobs/sync";
import { ProviderService } from "@backend/providers/provider.service";
import { Injectable } from "@nestjs/common";
import { DatabaseBackup } from "./backup";
import { BackgroundJob } from "./base";
import { PendingTransactionJob } from "./pending.transaction";

/** A central class that starts background job runners */
@Injectable()
export class JobsService {
  constructor(private providerService: ProviderService) {}

  /** A list of tracking background jobs that are running */
  private jobs: Array<BackgroundJob<any>> = [];

  /** The job that does background syncs */
  public providerSyncJob!: ProviderSyncJob;

  /** Starts the background jobs */
  async start() {
    // Database Backups
    if (Configuration.database.backup.enabled) this.jobs.push(await new DatabaseBackup().start());
    // Pending transaction
    this.jobs.push(await new PendingTransactionJob().start());
    // Provider syncs
    this.providerSyncJob = await new ProviderSyncJob(this.providerService).start();
    this.jobs.push(this.providerSyncJob);
  }
}
