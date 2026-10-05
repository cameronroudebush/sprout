import { CashFlowService } from "@backend/cash-flow/cash.flow.service";
import { Configuration } from "@backend/config/core";
import { TimeZone } from "@backend/config/model/tz";
import { WeeklyEmailContent } from "@backend/email/model/weekly-content";
import { NetWorthService } from "@backend/net-worth/net-worth.service";
import { User } from "@backend/user/model/user.model";
import { MailerService } from "@nestjs-modules/mailer";
import { BadRequestException, Injectable, Logger, OnModuleInit } from "@nestjs/common";
import { startOfDay, subDays } from "date-fns";
import { fromZonedTime, toZonedTime } from "date-fns-tz";
import { MoreThanOrEqual } from "typeorm";

/** A service that provides email capability to Sprout, assuming it's configured. */
@Injectable()
export class EmailService implements OnModuleInit {
  private readonly logger = new Logger("service:email");
  constructor(
    private readonly mailerService: MailerService,
    private readonly netWorthService: NetWorthService,
    private readonly cashFlowService: CashFlowService,
  ) {}

  async onModuleInit() {
    if (Configuration.server.email.enabled) {
      this.logger.log(`Email is enabled. Validating config...`);
      Configuration.server.email.validate();
      await this.mailerService.verifyAllTransporters();
    }
  }

  /** Returns the weekly email content for display from the given user */
  async getWeeklyEmailContent(user: User) {
    // Use the configured local day boundary so transactions from that day are not
    // lost when the email runs later than the exact 168-hour cutoff.
    const localNow = toZonedTime(new Date(), TimeZone.timeZone);
    const oneWeekAgo = fromZonedTime(startOfDay(subDays(localNow, 7)), TimeZone.timeZone);
    const dateRange = MoreThanOrEqual(oneWeekAgo);

    const { totalIncome, totalExpense, transactions } = await this.cashFlowService.calculateFlows(
      user,
      undefined,
      undefined,
      undefined,
      undefined,
      dateRange,
      true,
    );

    const netWorth = await this.netWorthService.getTotalSummary(user);

    return new WeeklyEmailContent(user, netWorth, totalExpense, totalIncome, transactions.length, transactions);
  }

  /** Sends the weekly update to the users email, if configured */
  async sendWeeklyUpdate(user?: User | null) {
    if (user == null) return; // Ignore undefined users
    if (!user.email) throw new BadRequestException("This user does not have an email specified");
    const context = await this.getWeeklyEmailContent(user);

    await this.mailerService.sendMail({
      to: user.email,
      from: Configuration.server.email.from,
      subject: "Weekly Sprout Update",
      template: "weekly-update",
      context,
    });
  }
}
