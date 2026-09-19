import { setupTests } from "@backend/test/helpers";
setupTests();

import { EmailService } from "@backend/email/email.service";
import { MailerService } from "@nestjs-modules/mailer";
import { NetWorthService } from "@backend/net-worth/net-worth.service";
import { CashFlowService } from "@backend/cash-flow/cash.flow.service";
import { Configuration } from "@backend/config/core";
import { TestEntities } from "@backend/test/entities";
import { BadRequestException } from "@nestjs/common";

describe("EmailService", () => {
  let service: EmailService;
  let mailerService: vi.Mocked<MailerService>;
  let netWorthService: vi.Mocked<NetWorthService>;
  let cashFlowService: vi.Mocked<CashFlowService>;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.clearAllMocks();

    mailerService = {
      verifyAllTransporters: vi.fn().mockResolvedValue(undefined),
      sendMail: vi.fn().mockResolvedValue(undefined),
    } as any;

    netWorthService = {
      getTotalSummary: vi.fn().mockResolvedValue(10000),
    } as any;

    cashFlowService = {
      calculateFlows: vi.fn().mockResolvedValue({
        totalIncome: 1000,
        totalExpense: 500,
        filteredTransactions: [TestEntities.transaction],
      }),
    } as any;

    service = new EmailService(mailerService, netWorthService, cashFlowService);
  });

  describe("onModuleInit", () => {
    it("should validate and verify transporters if email is enabled", async () => {
      const originalEnabled = Configuration.server.email.enabled;
      Configuration.server.email.enabled = true;

      await service.onModuleInit();

      expect(mailerService.verifyAllTransporters).toHaveBeenCalled();
      Configuration.server.email.enabled = originalEnabled;
    });

    it("should bypass verification if email is disabled", async () => {
      const originalEnabled = Configuration.server.email.enabled;
      Configuration.server.email.enabled = false;

      await service.onModuleInit();

      expect(mailerService.verifyAllTransporters).not.toHaveBeenCalled();
      Configuration.server.email.enabled = originalEnabled;
    });
  });

  describe("getWeeklyEmailContent", () => {
    it("should calculate flows and net worth summary for user email content", async () => {
      const content = await service.getWeeklyEmailContent(user);

      expect(cashFlowService.calculateFlows).toHaveBeenCalled();
      expect(netWorthService.getTotalSummary).toHaveBeenCalledWith(user);
      expect(content).toBeDefined();
    });
  });

  describe("sendWeeklyUpdate", () => {
    it("should do nothing if user is null or undefined", async () => {
      await service.sendWeeklyUpdate(null);
      expect(mailerService.sendMail).not.toHaveBeenCalled();
    });

    it("should throw BadRequestException if user lacks an email", async () => {
      const noEmailUser = { ...user, email: "" };
      await expect(service.sendWeeklyUpdate(noEmailUser as any)).rejects.toThrow(BadRequestException);
    });

    it("should send email update if user has email", async () => {
      await service.sendWeeklyUpdate(user);

      expect(mailerService.sendMail).toHaveBeenCalledWith(
        expect.objectContaining({
          to: user.email,
          subject: "Weekly Sprout Update",
          template: "weekly-update",
        }),
      );
    });
  });
});
