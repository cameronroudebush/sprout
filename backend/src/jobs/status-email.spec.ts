import { EmailService } from "@backend/email/email.service";
import { StatusEmailJob } from "@backend/jobs/status-email";
import { Test, TestingModule } from "@nestjs/testing";

describe("StatusEmailJob", () => {
  let job: StatusEmailJob;
  let emailService: EmailService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        StatusEmailJob,
        {
          provide: EmailService,
          useValue: {
            sendStatusUpdateForAllUsers: jest.fn(),
          },
        },
      ],
    }).compile();

    job = module.get<StatusEmailJob>(StatusEmailJob);
    emailService = module.get<EmailService>(EmailService);
  });

  describe("Constructor", () => {
    it("should instantiate with correct jobName", () => {
      expect(job.jobName).toBe("email:status");
    });
  });

  describe("update", () => {
    it("should call sendStatusUpdateForAllUsers on the EmailService", async () => {
      // By extending BackgroundJob, update() is protected, but we can test it directly
      await (job as any).update();
      expect(emailService.sendStatusUpdateForAllUsers).toHaveBeenCalled();
    });
  });
});
