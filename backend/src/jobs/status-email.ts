import { Configuration } from "@backend/config/core";
import { EmailService } from "@backend/email/email.service";
import { Injectable } from "@nestjs/common";
import { BackgroundJob } from "./base";

/** This class defines a background job that handles sending status emails out at certain times. */
@Injectable()
export class StatusEmailJob extends BackgroundJob<any> {
  constructor(private readonly emailService: EmailService) {
    super("email:status", Configuration.server.email.sendTime);
  }

  protected async update() {
    await this.emailService.sendStatusUpdateForAllUsers();
  }
}
