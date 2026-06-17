import { Configuration } from "@backend/config/core";
import { EmailService } from "@backend/email/email.service";
import { DistributedQueueJob } from "@backend/jobs/job-distributed-base";
import { EmailUpdateFrequency } from "@backend/user/model/user.config.model";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";
import { IsNull, Not } from "typeorm";

type EmailTaskPayload = { userId: string };

/** This class defines a background job that handles sending status emails out at certain times. */
@Injectable()
export class StatusEmailJob extends DistributedQueueJob<EmailTaskPayload> {
  constructor(private readonly emailService: EmailService) {
    super("email:status", Configuration.server.email.sendTime, Configuration.server.email.enabled);
  }

  protected async generateTasks(): Promise<EmailTaskPayload[]> {
    // Basic validation check before initializing bulk tasks
    Configuration.server.email.validate();

    const users = await User.find({
      where: {
        email: Not(IsNull()),
        config: { emailUpdateFrequency: EmailUpdateFrequency.WEEKLY },
      },
      select: { id: true },
    });

    this.logger.log(`Located ${users.length} users due for a status email update.`);
    return users.map((u) => ({ userId: u.id }));
  }

  protected async processTask(task: EmailTaskPayload): Promise<void> {
    try {
      const user = await User.findOne({ where: { id: task.userId } });
      await this.emailService.sendWeeklyUpdate(user);
    } catch (error) {
      this.logger.error(`Failed to process status email task for user ID ${task.userId}: ${(error as Error).message}`);
    }
  }
}
