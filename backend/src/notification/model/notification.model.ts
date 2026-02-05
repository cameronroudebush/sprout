import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { FirebaseNotificationDTO } from "@backend/notification/model/api/firebase.notification.dto";
import { User } from "@backend/user/model/user.model";
import { ApiHideProperty } from "@nestjs/swagger";
import { Exclude } from "class-transformer";
import { IsEnum } from "class-validator";
import { ManyToOne } from "typeorm";
import { NotificationType } from "./notification.type";

/** This class defines a notification that should be tracked on a per user basis to provide out-of-sync information to the user */
@DatabaseDecorators.entity()
export class Notification extends DatabaseBase {
  /** The title for our notification */
  @DatabaseDecorators.column({ nullable: false })
  title: string;

  /** The message that this notification intended to show the user */
  @DatabaseDecorators.column({ nullable: false })
  message: string;

  /** The type of notification this is */
  @DatabaseDecorators.column({ nullable: false, type: "varchar" })
  @IsEnum(NotificationType)
  type: NotificationType;

  /** The date that this notification occurs on */
  @DatabaseDecorators.column({ nullable: false })
  createdAt: Date = new Date();

  /** Tracks if the user has interacted with this notification yet. */
  @DatabaseDecorators.column({ default: false })
  isRead: boolean = false;

  @DatabaseDecorators.column({ nullable: true })
  readAt?: Date;

  /** The user this notification belongs to */
  @ManyToOne(() => User, (u) => u.id)
  @ApiHideProperty()
  @Exclude()
  user: User;

  constructor(user: User, title: string, message: string, type: NotificationType) {
    super();
    this.user = user;
    this.title = title;
    this.message = message;
    this.type = type;
  }

  /** Returns how important our notification is to applications */
  get importance(): FirebaseNotificationDTO["importance"] {
    switch (this.type) {
      case NotificationType.info:
      case NotificationType.success:
        return "default";
      case NotificationType.warning:
      case NotificationType.error:
        return "high";
    }
  }

  /** Returns how important it is to wake up the device to receive this notification */
  get powerPriority(): "high" | "normal" {
    switch (this.type) {
      case NotificationType.info:
      case NotificationType.success:
        return "normal";
      case NotificationType.warning:
      case NotificationType.error:
        return "high";
    }
  }
}
