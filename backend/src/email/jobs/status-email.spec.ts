import { setupTests } from "@backend/test/helpers";
setupTests();

import { Configuration } from "@backend/config/core";
import { EmailService } from "@backend/email/email.service";
import { StatusEmailJob } from "@backend/email/jobs/status-email";
import { EmailUpdateFrequency } from "@backend/user/model/user.config.model";
import { User } from "@backend/user/model/user.model";
import { IsNull, Not } from "typeorm";

describe("StatusEmailJob", () => {
  let job: StatusEmailJob;
  let emailService: Mocked<EmailService>;

  beforeEach(() => {
    vi.clearAllMocks();

    emailService = {
      sendWeeklyUpdate: vi.fn(),
    } as any;

    job = new StatusEmailJob(emailService);
  });

  describe("generateTasks", () => {
    it("should validate configurations, query targeted users with weekly configurations, and map down to queue payloads", async () => {
      const validateSpy = vi.spyOn(Configuration.server.email, "validate").mockImplementation(() => {});
      const findSpy = vi.spyOn(User, "find").mockResolvedValue([User.fromPlain({ id: "user-alpha" }), User.fromPlain({ id: "user-beta" })]);
      const logSpy = vi.spyOn((job as any).logger, "log");

      const result = await (job as any).generateTasks();

      expect(validateSpy).toHaveBeenCalled();
      expect(findSpy).toHaveBeenCalledWith({
        where: {
          email: Not(IsNull()),
          config: { emailUpdateFrequency: EmailUpdateFrequency.WEEKLY },
        },
        select: { id: true },
      });
      expect(logSpy).toHaveBeenCalledWith("Located 2 users due for a status email update.");
      expect(result).toEqual([{ userId: "user-alpha" }, { userId: "user-beta" }]);
    });
  });

  describe("processTask", () => {
    it("should load the precise user object and dispatch the operational transmission through email service parameters", async () => {
      const mockUser = User.fromPlain({ id: "user-alpha", email: "alpha@domain.local" });
      const findOneSpy = vi.spyOn(User, "findOne").mockResolvedValue(mockUser);
      emailService.sendWeeklyUpdate.mockResolvedValue(undefined);

      await (job as any).processTask({ userId: "user-alpha" });

      expect(findOneSpy).toHaveBeenCalledWith({ where: { id: "user-alpha" } });
      expect(emailService.sendWeeklyUpdate).toHaveBeenCalledWith(mockUser);
    });

    it("should swallow downstream dispatch failures safely and redirect details out to internal error log parameters", async () => {
      const mockUser = User.fromPlain({ id: "user-beta" });
      vi.spyOn(User, "findOne").mockResolvedValue(mockUser);
      emailService.sendWeeklyUpdate.mockRejectedValue(new Error("SMTP server unreachable"));
      const errorSpy = vi.spyOn((job as any).logger, "error");

      await expect((job as any).processTask({ userId: "user-beta" })).resolves.not.toThrow();
      expect(errorSpy).toHaveBeenCalledWith("Failed to process status email task for user ID user-beta: SMTP server unreachable");
    });
  });
});
