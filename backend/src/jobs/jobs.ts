import { Configuration } from "@backend/config/core";
import { DatabaseBackup } from "./backup";
import { BackgroundJob } from "./base";
import { PendingTransactionJob } from "./pending.transaction";

/** A central class that starts background job runners */
export class JobProcessor {
  /** A list of tracking background jobs that are running */
  private jobs: Array<BackgroundJob<any>> = [];

  /** Starts the background jobs */
  async start() {
    // Database Backups
    if (Configuration.database.backup.enabled) this.jobs.push(await new DatabaseBackup().start());
    // Pending transaction
    this.jobs.push(await new PendingTransactionJob().start());
  }
}
