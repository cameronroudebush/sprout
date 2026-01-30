import { Configuration } from "@backend/config/core";
import { FirebaseNotificationDTO } from "@backend/notification/model/api/firebase.notification.dto";
import { NotificationSSEDTO } from "@backend/notification/model/api/notification.sse.dto";
import { Notification } from "@backend/notification/model/notification.model";
import { NotificationType } from "@backend/notification/model/notification.type";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { UserDevice } from "@backend/user/model/user.device.model";
import { User } from "@backend/user/model/user.model";
import { Injectable, Logger, OnModuleInit } from "@nestjs/common";
import * as admin from "firebase-admin";

/** This service provides re-usable capability to notify users of specific interactions. */
@Injectable()
export class NotificationService implements OnModuleInit {
  private readonly logger = new Logger("service:notification");

  constructor(private sseService: SSEService) {}

  onModuleInit() {
    // Initialize firebase, if enabled
    if (Configuration.server.notification.firebase.enabled) {
      this.logger.log(`Firebase is enabled. Validating config.`);
      Configuration.server.notification.firebase.validate();
      admin.initializeApp({
        credential: admin.credential.cert({
          projectId: Configuration.server.notification.firebase.projectId,
          clientEmail: Configuration.server.notification.firebase.clientEmail,
          privateKey: Configuration.server.notification.firebase.privateKey.replace(/\\n/g, "\n"),
        }),
      });
    }
  }

  /**
   * Notifies the user with the given information by adding notifications related to them and telling the
   *  frontend's about the new notification.
   *
   * @param notifyDevices If true, attempts to use firebase to inform their sleeping app of the notification via secure methods.
   */
  async notifyUser(user: User, message: string, title: string, type: NotificationType, notifyDevices = true) {
    const n = new Notification(user, title, message, type);
    await n.insert();
    await this.cleanupUserMax(user);
    // Tell user devices of new notifications that should be requested.
    this.sseService.sendToUser(user, SSEEventType.NOTIFICATION, new NotificationSSEDTO(true));
    if (notifyDevices) await this.notifyApp(user, n);
    return n;
  }

  /**
   * Notifies connected apps that new notifications should be pulled via firebase.
   *  This notification doesn't contain any actual content as it's just expected to wake up the app. The
   *  app is expected to grab new notifications with the awaken.
   *
   * @param importance How to treat this notification when it appears on the device
   * @param powerPriority Defines how the OS handles the device's power state for this notification. High will wake up the device. Default is normal.
   */
  private async notifyApp(
    user: User,
    notification: Notification,
    importance: FirebaseNotificationDTO["importance"] = "default",
    powerPriority: "high" | "normal" = "normal",
  ) {
    // Don't send if not enabled
    if (!Configuration.server.notification.firebase.enabled) return;
    // Find all devices related to the current user
    const devices = await UserDevice.find({ where: { user: { id: user.id } } });

    if (devices.length === 0) {
      this.logger.warn(`No devices associated to user ${user.username}`);
      return;
    }

    // Notify all of the users devices
    for (const device of devices) {
      const message: admin.messaging.Message = {
        token: device.fcmToken,
        data: new FirebaseNotificationDTO({ notificationId: notification.id, importance }) as { [key: string]: any },
        android: { priority: powerPriority },
        apns: { payload: { aps: { contentAvailable: true } } },
      };

      try {
        await admin.messaging().send(message);
      } catch (error) {
        this.logger.error(error);
        // If the token is invalid (app uninstalled), clean it up immediately
        if ((error as any).code === "messaging/registration-token-not-registered") {
          await UserDevice.delete({ fcmToken: device.fcmToken });
        }
      }
    }
  }

  /** Cleans up the number of notifications this user can have so they don't have too many */
  private async cleanupUserMax(user: User) {
    const maxNotifications = Configuration.server.notification.maxNotificationsPerUser;

    const notifications = await Notification.find({
      where: { user: { id: user.id } },
      order: { createdAt: "DESC" },
    });

    // If we have more than the limit, identify the ones to delete
    if (notifications.length > maxNotifications) {
      const excessNotifications = notifications.slice(maxNotifications);
      const idsToDelete = excessNotifications.map((n) => n.id);
      await Notification.deleteMany(idsToDelete);
    }
  }
}
