import { Configuration } from "@backend/config/core";
import { Utility } from "@backend/core/model/utility/utility";
import { DistributedQueueJob } from "@backend/jobs/job-distributed-base";
import { Sync } from "@backend/jobs/model/sync.model";
import { NotificationType } from "@backend/notification/model/notification.type";
import { NotificationService } from "@backend/notification/notification.service";
import { ProviderType } from "@backend/providers/base/provider.type";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";
import { In } from "typeorm";

/** Payload for the notification worker */
type SyncNotificationPayload = { userId: string };

/** A job that checks provider syncs on a schedule to see when users need notified. This allows us to aggregate the notifications. */
@Injectable()
export class SyncNotificationJob extends DistributedQueueJob<SyncNotificationPayload> {
  constructor(
    private readonly notificationService: NotificationService,
    private readonly sseService: SSEService,
  ) {
    super("provider:sync:notification", Configuration.providers.syncNotifications.time, Configuration.providers.syncNotifications.enabled);
  }

  protected async generateTasks(): Promise<SyncNotificationPayload[]> {
    const pendingUsers = await Sync.getRepository()
      .createQueryBuilder()
      .select("sync.userId", "userId")
      .where("sync.notified = :notified", { notified: false })
      .andWhere("sync.status IN (:...statuses)", { statuses: ["complete", "failed"] })
      .groupBy("sync.userId")
      .getRawMany();
    this.logger.debug(`${pendingUsers.length} user(s) have notifications to send.`);
    return pendingUsers.map((row) => ({ userId: row.userId }));
  }

  async processTask(task: SyncNotificationPayload) {
    const user = await User.findOne({ where: { id: task.userId } });
    if (!user) return;

    // Fetch un-notified syncs specifically for this user
    const syncs = await Sync.find({
      where: {
        user: { id: user.id },
        notified: false,
        status: In(["complete", "failed"]),
      },
    });

    // Deduplicate (only notify them of the latest status per provider)
    const latestSyncs = this.deduplicateByProvider(syncs);

    try {
      this.logger.debug(`Sending aggregation for ${user.username}.`);
      // Send the batched notification
      await this.sendDigest(user, latestSyncs);
      // Mark all as notified
      const ids = syncs.map((s) => s.id);
      await Sync.updateWhere({ id: In(ids) }, { notified: true });
    } catch (e) {
      this.logger.error(`Failed to send digest for user ${user.id}: ${(e as Error).message}`);
      throw e;
    }
  }

  /**
   * Keeps only the newest sync record per provider to prevent duplicate info
   *  in case a single provider triggered multiple times within the digest window.
   */
  private deduplicateByProvider(syncs: Sync[]): Sync[] {
    const map = new Map<ProviderType, Sync>();
    for (const sync of syncs) {
      const existing = map.get(sync.provider);
      if (!existing || sync.time > existing.time) map.set(sync.provider, sync);
    }
    return Array.from(map.values());
  }

  async sendDigest(user: User, recentSyncs: Sync[]) {
    // Categorize the outcomes
    const successes = recentSyncs.filter((s) => s.status === "complete");
    const failures = recentSyncs.filter((s) => s.status === "failed");

    // Real-time UI refresh, if at-least one provider succeeded
    if (successes.length > 0) this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);

    // Handle Notifications
    if (failures.length > 0) {
      // Aggregate errors and combine them by provider
      const combinedErrorDetails = failures.map((f) => `${f.failureReason || "Unknown error"}`).join(" | ");

      // Send the single aggregation
      await this.notificationService.notifyUser(
        user,
        `We had trouble syncing some accounts: ${combinedErrorDetails}`,
        "Connection Error",
        NotificationType.error,
      );
    } else if (successes.length > 0) {
      // All successful, only send one message which is auto rate limited thanks to the cron job timer.
      const message = this.getSuccessMessage();
      await this.notificationService.notifyUser(user, message.body, message.title, NotificationType.success);
    }
  }

  /** Returns a random message for a success when this provider is updated. */
  private getSuccessMessage() {
    return Utility.randomFromArray([
      { title: `Accounts Synced`, body: `Your accounts are up to date.` },
      { title: "You're All Caught Up", body: "We've finished syncing your accounts." },
    ]);
  }
}
