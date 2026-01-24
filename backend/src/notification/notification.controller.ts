import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { FirebaseConfigDTO } from "@backend/notification/model/api/firebase.config.dto";
import { FirebaseNotificationDTO } from "@backend/notification/model/api/firebase.notification.dto";
import { Notification } from "@backend/notification/model/notification.model";
import { User } from "@backend/user/model/user.model";
import { Controller, Get, Param } from "@nestjs/common";
import { ApiExtraModels, ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";

/** This controller provides the endpoint for all notification related content per user */
@Controller("notification")
@ApiTags("Notification")
@ApiExtraModels(FirebaseNotificationDTO)
@AuthGuard.attach()
export class NotificationController {
  constructor() {}

  @Get()
  @ApiOperation({
    summary: "Get's the notifications",
    description: "Returns all the notifications for the currently authenticated user.",
  })
  @ApiOkResponse({ description: "Notifications retrieved successfully.", type: [Notification] })
  async getNotifications(@CurrentUser() user: User) {
    return await Notification.find({ where: { user: { id: user.id } } });
  }

  @Get(":id")
  @ApiOperation({
    summary: "Get's a notification by it's id.",
    description: "Returns a specific notification for the specific user by it's ID.",
  })
  @ApiOkResponse({ description: "Notifications retrieved successfully.", type: Notification })
  async getById(@Param("id") id: string, @CurrentUser() user: User) {
    return await Notification.findOne({ where: { id, user: { id: user.id } } });
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
