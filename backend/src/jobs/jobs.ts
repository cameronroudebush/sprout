import { Configuration } from "@backend/config/core";
import { ProviderSyncJob } from "@backend/jobs/sync";
import { DatabaseBackup } from "./backup";
import { BackgroundJob } from "./base";
import { PendingTransactionJob } from "./pending.transaction";

/** A central class that starts background job runners */
export class JobProcessor {
  /** A list of tracking background jobs that are running */
  private static jobs: Array<BackgroundJob<any>> = [];

  /** The job that does background syncs */
  public static providerSyncJob: ProviderSyncJob;

  /** Starts the background jobs */
  static async start() {
    // Database Backups
    if (Configuration.database.backup.enabled) this.jobs.push(await new DatabaseBackup().start());
    // Pending transaction
    this.jobs.push(await new PendingTransactionJob().start());
    // Provider syncs
    this.providerSyncJob = await new ProviderSyncJob().start();
    this.jobs.push(this.providerSyncJob);
  }
}
