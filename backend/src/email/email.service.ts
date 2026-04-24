import { Configuration } from "@backend/config/core";
import { WeeklyEmailContent } from "@backend/email/model/weekly-content";
import { NetWorthService } from "@backend/net-worth/net-worth.service";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { EmailUpdateFrequency } from "@backend/user/model/user.config.model";
import { User } from "@backend/user/model/user.model";
import { MailerService } from "@nestjs-modules/mailer";
import { BadRequestException, Injectable, Logger, OnModuleInit } from "@nestjs/common";
import { subDays } from "date-fns";
import { IsNull, MoreThanOrEqual, Not } from "typeorm";

/** A service that provides email capability to Sprout, assuming it's configured. */
@Injectable()
export class EmailService implements OnModuleInit {
  private readonly logger = new Logger("service:email");
  constructor(
    private readonly mailerService: MailerService,
    private readonly netWorthService: NetWorthService,
  ) {}

  async onModuleInit() {
    if (Configuration.server.email.enabled) {
      this.logger.log(`Email is enabled. Validating config...`);
      Configuration.server.email.validate();
      await this.mailerService.verifyAllTransporters();
    }
  }

  /** Sends status email updates for all users with it enabled. Collects data for the last week. */
  async sendStatusUpdateForAllUsers() {
    Configuration.server.email.validate();
    const users = await User.find({ where: { email: Not(IsNull()), config: { emailUpdateFrequency: EmailUpdateFrequency.WEEKLY } } });
    this.logger.debug(`Located ${users.length} to update`);
    await Promise.all(users.map((user) => this.sendWeeklyUpdate(user)));
  }

  /** Sends the weekly update to the users email, if configured */
  async sendWeeklyUpdate(user: User) {
    // This will be checked by {@link sendStatusUpdateForAllUsers}, but this is just in case
    if (!user.email) throw new BadRequestException("This user does not have an email specified");
    // Build the content for this user
    const oneWeekAgo = subDays(new Date(), 7);
    const transactions = await Transaction.find({
      where: { account: { user: { id: user.id } }, posted: MoreThanOrEqual(oneWeekAgo) },
      order: { posted: "DESC" },
    });
    const netWorth = await this.netWorthService.getTotalSummary(user);
    const weeklyIncome = transactions.reduce((sum, tx) => (tx.amount > 0 ? sum + tx.amount : sum), 0);
    const weeklyExpense = transactions.reduce((sum, tx) => (tx.amount < 0 ? sum + Math.abs(tx.amount) : sum), 0);

    const context = new WeeklyEmailContent(
      user,
      netWorth,
      weeklyExpense,
      weeklyIncome,
      transactions.length,
      transactions.map((x) => ({ description: x.description, category: x.category?.name ?? "", amount: x.amount })),
    );

    await this.mailerService.sendMail({
      to: user.email,
      from: Configuration.server.email.from,
      subject: "Weekly Sprout Update",
      template: "weekly-update",
      context,
    });
  }
}
