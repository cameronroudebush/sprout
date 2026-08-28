import { ProviderType } from "@backend/providers/base/provider.type";
import { ProviderSyncJob } from "@backend/providers/jobs/sync";
import { Sync } from "@backend/providers/model/sync.model";
import { User } from "@backend/user/model/user.model";
import { Injectable, NotFoundException } from "@nestjs/common";
import { DiscoveryService } from "@nestjs/core";

@Injectable()
export class ProviderService {
  /** Dynamically discovers all active ProviderSyncJobs registered in NestJS */
  private getActiveSyncJobs(): ProviderSyncJob[] {
    return this.discoveryService
      .getProviders()
      .flatMap((wrapper) => wrapper.instance)
      .filter((instance): instance is ProviderSyncJob => instance instanceof ProviderSyncJob);
  }

  constructor(private readonly discoveryService: DiscoveryService) {}

  async syncUserProviders(user: User, notify: boolean, providerType: ProviderType): Promise<Sync | undefined>;
  async syncUserProviders(user: User, notify: boolean): Promise<(Sync | undefined)[]>;
  /**
   * Triggers background sync tasks for a user across all providers, or a specific target provider.
   *
   * @param user The target user to sync
   * @param notify Whether to issue notifications
   * @param providerType Optional specific provider to target. If omitted, syncs all providers.
   */
  async syncUserProviders(user: User, notify: boolean, providerType?: ProviderType): Promise<Sync | (Sync | undefined)[] | undefined> {
    const jobs = this.getActiveSyncJobs();
    if (providerType) {
      const targetJob = jobs.find((j) => j.provider.config.dbType === providerType);
      if (!targetJob) throw new NotFoundException(`Sync job runner for provider '${providerType}' was not found or is disabled.`);

      return await targetJob.processTask({ userId: user.id, notify });
    }
    return await Promise.all(jobs.map((job) => job.processTask({ userId: user.id, notify })));
  }
}
