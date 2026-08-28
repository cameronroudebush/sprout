import { DistributedQueueJob } from "@backend/core/jobs/model/job-distributed-base";
import { ProviderBase } from "@backend/providers/base/core";
import { ProviderSyncService } from "@backend/providers/base/sync.service";
import { Sync } from "@backend/providers/model/sync.model";
import { User } from "@backend/user/model/user.model";
import { subDays } from "date-fns";
import { LessThan } from "typeorm";

/** Represents the type for the distributed jobs */
type SyncTaskPayload = {
  userId: string;
  /** If we should notify the user of these results */
  notify?: boolean;
};

/** This sync job specifies a singular job for a specific provider. This is re-used for every provider and dynamically created based on provider count. */
export class ProviderSyncJob extends DistributedQueueJob<SyncTaskPayload> {
  constructor(
    public readonly provider: ProviderBase,
    private readonly providerSyncService: ProviderSyncService,
  ) {
    const config = provider.getAppConfiguration();
    super(`provider:sync:${provider.config.dbType}`, config.syncFrequency, config.enabled);
  }

  // Grabs all active user IDs and queues them. Cleans up old syncs once per cycle.
  protected async generateTasks(): Promise<SyncTaskPayload[]> {
    // Run DB cleanup for old sync records while the lock is held
    await this.cleanupOldSyncs();

    const users = await User.find({ select: { id: true } });
    return users.map((u) => ({ userId: u.id }));
  }

  // Orchestrates the sync lifecycle, error handling, and sync history for a single user
  async processTask(task: SyncTaskPayload) {
    const user = await User.findOne({ where: { id: task.userId } });
    if (!user) return;
    return await this.providerSyncService.syncForProvider(user, this.provider, task.notify);
  }

  /** Cleans up old sync history to prevent table bloat */
  private async cleanupOldSyncs(days = 60) {
    try {
      const cutoffDate = subDays(new Date(), days);
      const result = await Sync.delete({
        time: LessThan(cutoffDate),
        provider: this.provider.config.dbType,
      });
      if (result.affected && result.affected > 0) this.logger.log(`Removed ${result.affected} old sync record(s).`);
    } catch (e) {
      this.logger.error(`Failed to cleanup old sync records: ${(e as Error).message}`);
    }
  }
}
