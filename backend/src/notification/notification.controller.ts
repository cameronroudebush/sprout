import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { FirebaseConfigDTO } from "@backend/notification/model/api/firebase.config.dto";
import { FirebaseNotificationDTO } from "@backend/notification/model/api/firebase.notification.dto";
import { NotificationSSEDTO } from "@backend/notification/model/api/notification.sse.dto";
import { Notification } from "@backend/notification/model/notification.model";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { Controller, Get, Param, ParseUUIDPipe } from "@nestjs/common";
import { ApiExtraModels, ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";

/** This controller provides the endpoint for all notification related content per user */
@Controller("notification")
@ApiTags("Notification")
@ApiExtraModels(FirebaseNotificationDTO, NotificationSSEDTO)
@AuthGuard.attach()
export class NotificationController {
  constructor(private sseService: SSEService) {}

  @Get()
  @ApiOperation({
    summary: "Get's the notifications",
    description: "Returns all the notifications for the currently authenticated user.",
  })
  @ApiOkResponse({ description: "Notifications retrieved successfully.", type: [Notification] })
  async getNotifications(@CurrentUser() user: User) {
    return await Notification.find({ where: { user: { id: user.id } }, order: { createdAt: "DESC" } });
  }

  @Get(":id")
  @ApiOperation({
    summary: "Get's a notification by it's id.",
    description: "Returns a specific notification for the specific user by it's ID.",
  })
  @ApiOkResponse({ description: "Notifications retrieved successfully.", type: Notification })
  async getById(@Param("id", new ParseUUIDPipe()) id: string, @CurrentUser() user: User) {
    return await Notification.findOne({ where: { id, user: { id: user.id } } });
  }

  @Get("read/all")
  @ApiOperation({
    summary: "Marks all notifications read.",
    description: "Used for when the user opens their notification shade.",
  })
  @ApiOkResponse({ description: "Notifications marked read successfully." })
  async markAllRead(@CurrentUser() user: User) {
    // Update all the notifications
    await Notification.updateWhere({ user: { id: user.id } }, { readAt: new Date(), isRead: true });
    this.sseService.sendToUser(user, SSEEventType.NOTIFICATION, new NotificationSSEDTO(false));
  }

  @Get("read/:id")
  @ApiOperation({
    summary: "Marks a specific notification read.",
    description: "Marks the given ID's notification read.",
  })
  @ApiOkResponse({ description: "Notification marked read successfully." })
  async markRead(@Param("id", new ParseUUIDPipe()) id: string, @CurrentUser() user: User) {
    await Notification.updateWhere({ id: id, user: { id: user.id } }, { readAt: new Date(), isRead: true });
    // Inform of updated notifications
    this.sseService.sendToUser(user, SSEEventType.NOTIFICATION, new NotificationSSEDTO(false));
  }

  @Get("config/firebase")
  @ApiOperation({
    summary: "Returns the firebase configuration.",
    description:
      "Since this is a self hosted app, if you want notifications you must configure them manually. This endpoint provides the config to the frontend's.",
  })
  @ApiOkResponse({ description: "Firebase configuration retrieved successfully.", type: FirebaseConfigDTO })
  getFirebaseConfig() {
    return FirebaseConfigDTO.fromConfig();
  }
}
