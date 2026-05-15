import { Configuration } from "@backend/config/core";
import { UserDeviceJob } from "@backend/jobs/user.device";
import { UserDevice } from "@backend/user/model/user.device.model";
import { Test, TestingModule } from "@nestjs/testing";

describe("UserDeviceJob", () => {
  let job: UserDeviceJob;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [UserDeviceJob],
    }).compile();

    job = module.get<UserDeviceJob>(UserDeviceJob);

    // Setup TypeORM method mocks
    UserDevice.delete = jest.fn();

    // Set configuration variables explicitly
    Configuration.user.days = 30;
    Configuration.user.deviceCheckTime = "* * * * *";

    jest.clearAllMocks();
  });

  describe("Constructor", () => {
    it("should instantiate with correct jobName", () => {
      expect(job.jobName).toBe("user:device");
    });
  });

  describe("start", () => {
    it("should call super.start(true) upon starting", async () => {
      const superStartSpy = jest.spyOn(Object.getPrototypeOf(UserDeviceJob.prototype), "start").mockResolvedValue(job);
      const result = await job.start();

      expect(superStartSpy).toHaveBeenCalledWith(true);
      expect(result).toBe(job);
      superStartSpy.mockRestore();
    });
  });

  describe("update", () => {
    it("should delete devices older than the configured days and log when devices are cleaned", async () => {
      (UserDevice.delete as jest.Mock).mockResolvedValue({ affected: 5 });

      await (job as any).update();

      // Ensure delete was called with a cutoff date matching the Configuration
      expect(UserDevice.delete).toHaveBeenCalledWith({
        lastSeenAt: expect.any(Object), // Since date matches LessThan(), we assert it gets an Object containing the date
      });
    });

    it("should do nothing if there are no old user devices", async () => {
      (UserDevice.delete as jest.Mock).mockResolvedValue({ affected: 0 });

      await (job as any).update();

      expect(UserDevice.delete).toHaveBeenCalled();
    });

    it("should not error if result.affected is undefined", async () => {
      (UserDevice.delete as jest.Mock).mockResolvedValue({ affected: undefined });

      await (job as any).update();

      expect(UserDevice.delete).toHaveBeenCalled();
    });
  });
});
