import { ChatService } from "@backend/chat/chat.service";
import { ChatOverviewType } from "@backend/chat/model/chat.overview.type";
import { Configuration } from "@backend/config/core";
import { DefaultTaskPayload, DistributedQueueJob } from "@backend/core/jobs/model/job-distributed-base";
import { Utility } from "@backend/core/model/utility/utility";
import { NotificationType } from "@backend/notification/model/notification.type";
import { NotificationService } from "@backend/notification/notification.service";
import { ProviderType } from "@backend/providers/base/provider.type";
import { Sync } from "@backend/providers/model/sync.model";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { UserDevice } from "@backend/user/model/user.device.model";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";
import { startOfDay, subDays } from "date-fns";
import { In, MoreThan } from "typeorm";

/** A job that checks provider syncs on a schedule to handle informing users of new data and generating follow-up after providers are synced. */
@Injectable()
export class PostSyncProcessingJob extends DistributedQueueJob {
  private readonly successMessages = [
    { title: `Accounts Synced`, body: `Your accounts are up to date.` },
    { title: "You're All Caught Up", body: "We've finished syncing your accounts." },
  ];

  constructor(
    private readonly notificationService: NotificationService,
    private readonly sseService: SSEService,
    private readonly chatService: ChatService,
  ) {
    super("provider:post-sync", Configuration.providers.postSyncTime, true);
  }

  protected async generateTasks() {
    const pendingUsers = await Sync.getRepository()
      .createQueryBuilder("sync")
      .select("sync.userId", "userId")
      .where("sync.notified = :notified", { notified: false })
      .andWhere("sync.status IN (:...statuses)", { statuses: ["complete", "failed"] })
      .andWhere((qb) => {
        const subQuery = qb
          .subQuery()
          .select("1")
          .from(Sync, "pendingSync")
          .where("pendingSync.userId = sync.userId")
          .andWhere("pendingSync.status = :pendingStatus", { pendingStatus: "pending" })
          .getQuery();
        return `NOT EXISTS ${subQuery}`;
      })
      .groupBy("sync.userId")
      .getRawMany();

    this.logger.debug(`${pendingUsers.length} user(s) have notifications to send.`);
    return pendingUsers.map((row) => ({ userId: row.userId }));
  }

  async processTask(task: DefaultTaskPayload) {
    const user = await User.findOne({ where: { id: task.userId } });
    if (!user) return;

    // Double-check if the user still has syncs in progress
    const activeSyncCount = await Sync.count({
      where: {
        user: { id: user.id },
        status: "in-progress",
      },
    });

    if (activeSyncCount > 0) {
      this.logger.debug(`Deferring post-sync processing for ${user.username}: ${activeSyncCount} sync(s) still pending.`);
      return;
    }

    // Fetch un-notified syncs specifically for this user
    const syncs = await Sync.find({
      where: {
        user: { id: user.id },
        notified: false,
        status: In(["complete", "failed"]),
      },
    });

    if (syncs.length === 0) return;

    // Deduplicate (only notify them of the latest status per provider)
    const latestSyncs = this.deduplicateByProvider(syncs);

    try {
      this.logger.debug(`Sending aggregation for ${user.username}.`);
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

  /** Handles what to do based on sync status for the given user */
  async sendDigest(user: User, recentSyncs: Sync[]) {
    // Categorize the outcomes
    const successes = recentSyncs.filter((s) => s.status === "complete");
    const failures = recentSyncs.filter((s) => s.status === "failed");

    // Real-time UI refresh, if at-least one provider succeeded
    if (successes.length > 0) {
      this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);

      // Proactively regenerate AI overviews
      this.regenerateOverviewsIfActive(user);
    }

    // Handle Notifications, only if enabled
    if (Configuration.providers.syncNotifications.enabled) {
      // Check if the user has already received a notification today
      const today = startOfDay(new Date());
      const syncsProcessedToday = await Sync.count({
        where: {
          user: { id: user.id },
          notified: true,
          isManual: false,
          time: MoreThan(today),
        },
      });

      if (syncsProcessedToday > 0) {
        this.logger.debug(`Silent sync for ${user.username}. Notification already sent today.`);
        return;
      }

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
        const message = this.getSuccessMessage();
        await this.notificationService.notifyUser(user, message.body, message.title, NotificationType.success);
      }
    }
  }

  /**
   * Regenerates AI overviews if the user has used the app recently enough.
   * @param activeDaysThreshold How many days ago a user is considered "active" if within this window. This means if a user
   *  hasn't logged in for 7 days (or whatever this value is), they won't have overviews generated.
   */
  private async regenerateOverviewsIfActive(user: User, activeDaysThreshold = 7) {
    if (!Configuration.server.prompt.enabled) return; // Validate chat is enabled before trying to do this
    try {
      const recentDate = subDays(new Date(), activeDaysThreshold);
      const activeDevicesCount = await UserDevice.count({
        where: {
          user: { id: user.id },
          lastSeenAt: MoreThan(recentDate),
        },
      });

      if (activeDevicesCount === 0) {
        this.logger.debug(`Skipping overview generation for ${user.username}: No active devices in the last ${activeDaysThreshold} days.`);
        return;
      }

      this.logger.debug(`Background generating fresh overviews for active user ${user.username}.`);
      const model = await this.chatService.getModel(user);
      const overviewTypes = Object.values(ChatOverviewType) as ChatOverviewType[];
      // Sequentially generate overviews to avoid bursting the API
      for (const type of overviewTypes) {
        try {
          await model.generateOverview(type);
        } catch (e) {
          // Log the individual failure but continue to the next overview type
          this.logger.error(`Failed to generate ${type} overview for ${user.username}: ${(e as Error).message}`);
        }
      }
    } catch (e) {
      this.logger.error(`Failed to generate overviews for ${user.username}: ${(e as Error).message}`);
    }
  }

  /** Returns a random message for a success when this provider is updated. */
  private getSuccessMessage() {
    return Utility.randomFromArray(this.successMessages);
  }
}
