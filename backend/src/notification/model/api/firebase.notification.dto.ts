import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString } from "class-validator";

export class FirebaseNotificationDTO {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  notificationId!: string;

  @ApiProperty({ default: "secure_message" })
  @IsString()
  type: string = "secure_message";

  /**
   * Max / High	Heads-up (Pop-over banner)	Critical alerts, alarms, incoming calls, 2FA codes.
   * Default	Icon in status bar, shows in list
   * Low	Icon in status bar, shows in list
   * Min	Collapsed in shade, no icon
   */
  @ApiProperty({
    enum: ["max", "high", "default", "low"],
    default: "low",
    description: "Notification importance level",
  })
  @IsString()
  importance: "max" | "high" | "default" | "low" = "default";

  constructor(init?: Partial<FirebaseNotificationDTO>) {
    Object.assign(this, init);
  }
}
