import { DistributedQueueJob } from "@backend/jobs/job-distributed-base";
import { Sync } from "@backend/jobs/model/sync.model";
import { ProviderBase } from "@backend/providers/base/core";
import { ProviderType } from "@backend/providers/base/provider.type";
import { ProviderSyncService } from "@backend/providers/base/sync.service";
import { PROVIDER_LIST_TOKEN } from "@backend/providers/model/constants";
import { User } from "@backend/user/model/user.model";
import { Inject, Injectable, OnApplicationBootstrap } from "@nestjs/common";
import { subDays } from "date-fns";
import { LessThan } from "typeorm";

/** Represents the type for the distributed jobs */
type SyncTaskPayload = {
  userId: string;
  /** If we should notify the user of these results */
  notify?: boolean;
};

/** This job is the orchestrator that controls syncing all available providers */
@Injectable()
export class ProviderSyncOrchestratorJob implements OnApplicationBootstrap {
  /** List of jobs for each provider that we have initialized */
  jobs: Array<ProviderSyncJob> = [];

  constructor(
    private readonly providerSyncService: ProviderSyncService,
    @Inject(PROVIDER_LIST_TOKEN) private readonly providers: ProviderBase[],
  ) {}

  async onApplicationBootstrap() {
    this.jobs = await Promise.all(this.providers.map(async (x) => await new ProviderSyncJob(x, this.providerSyncService).start()));
  }

  /**
   * Public API to trigger a manual sync for a specific user across all active providers.
   * Pushes the tasks directly to the distributed/local queues.
   */
  async syncUserAllProviders(user: User, notify: boolean) {
    return await Promise.all(this.jobs.map(async (job) => await job.processTask({ userId: user.id, notify })));
  }

  /** Targets and invokes a background sync task for a single specific provider type */
  async syncUserSingleProvider(user: User, providerType: ProviderType, notify: boolean) {
    const targetJob = this.jobs.find((job) => job.provider.config.dbType === providerType);
    if (!targetJob) throw new Error(`Sync job runner for provider type '${providerType}' was not found or is disabled.`);
    return await targetJob.processTask({ userId: user.id, notify });
  }
}

/** The nested job for each specific actual provider */
class ProviderSyncJob extends DistributedQueueJob<SyncTaskPayload> {
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
