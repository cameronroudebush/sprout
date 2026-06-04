import { setupTests } from "@backend/test/helpers";
setupTests();

import { Configuration } from "@backend/config/core";
import { TimeZone } from "@backend/config/model/tz";
import { BackgroundJob } from "@backend/jobs/job-base";
import { Logger } from "@nestjs/common";
import CronExpressionParser from "cron-parser";

class TestBackgroundJob extends BackgroundJob<string> {
  public updateCount = 0;
  public shouldFail = false;

  protected async update(): Promise<string> {
    this.updateCount++;
    if (this.shouldFail) {
      throw new Error("Simulated job process failure");
    }
    return "completed";
  }
}

describe("BackgroundJob", () => {
  let job: TestBackgroundJob;
  let mockCronExpression: any;

  beforeEach(() => {
    jest.clearAllMocks();
    jest.useFakeTimers();

    Configuration.isRunningScript = false;
    Configuration.server = {
      jobs: {
        autoRetryTime: 5,
      },
    } as any;

    mockCronExpression = {
      next: jest.fn().mockReturnValue({
        toDate: jest.fn().mockReturnValue(new Date(Date.now() + 60000)),
      }),
    };
    jest.spyOn(CronExpressionParser, "parse").mockReturnValue(mockCronExpression);
    jest.spyOn(TimeZone, "formatDate").mockReturnValue("2026-06-02 12:00:00");
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  describe("Constructor and Initial Alignment", () => {
    it("should instantiate correctly, establish proper logging sub-contexts, and invoke chron-parsers with target timezones", () => {
      job = new TestBackgroundJob("VerificationJob", "*/5 * * * *", true);

      expect(job.jobName).toBe("VerificationJob");
      expect(CronExpressionParser.parse).toHaveBeenCalledWith("*/5 * * * *", { tz: TimeZone.timeZone });
    });
  });

  describe("start", () => {
    it("should exit execution path early returning self instance directly if runtime environments indicate a script execution run", async () => {
      Configuration.isRunningScript = true;
      job = new TestBackgroundJob("ScriptJob", "0 0 * * *", true);
      const logSpy = jest.spyOn((job as any).logger, "log");

      const result = await job.start();

      expect(result).toBe(job);
      expect(logSpy).not.toHaveBeenCalled();
    });

    it("should log warning messages without setting up internal setTimeout scheduling structures if enabled flag reflects false parameters", async () => {
      job = new TestBackgroundJob("DisabledJob", "0 0 * * *", false);
      const warnSpy = jest.spyOn((job as any).logger, "warn");
      const logSpy = jest.spyOn((job as any).logger, "log");

      await job.start();

      expect(warnSpy).toHaveBeenCalledWith("Job is disabled. This job will only run as manually requested.");
      expect(logSpy).not.toHaveBeenCalled();
      expect(jest.getTimerCount()).toBe(0);
    });

    it("should immediately invoke update actions prior to establishing cyclic interval timers if parameter overrides demand instant processing", async () => {
      job = new TestBackgroundJob("InstantJob", "0 0 * * *", true, true);
      const logSpy = jest.spyOn((job as any).logger, "log");

      await job.start();

      expect(logSpy).toHaveBeenCalledWith("Job is requesting to run immediately. Executing...");
      expect(job.updateCount).toBe(1);
      expect(logSpy).toHaveBeenCalledWith("Initializing background job of: 0 0 * * *");
      expect(jest.getTimerCount()).toBe(1);
    });

    it("should skip explicit execution and transition cleanly into timeline timer registration paths if immediate triggers are false", async () => {
      job = new TestBackgroundJob("StandardJob", "0 0 * * *", true, false);
      const logSpy = jest.spyOn((job as any).logger, "log");

      await job.start();

      expect(job.updateCount).toBe(0);
      expect(logSpy).toHaveBeenCalledWith("Initializing background job of: 0 0 * * *");
      expect(jest.getTimerCount()).toBe(1);
    });
  });

  describe("scheduleNextUpdate Loops", () => {
    it("should process update logic smoothly when execution dates approach and cascade recursively into downstream scheduling iterations", async () => {
      job = new TestBackgroundJob("LoopJob", "0 * * * *", true);
      await job.start();

      expect(job.updateCount).toBe(0);

      await jest.advanceTimersByTimeAsync(60000);

      expect(job.updateCount).toBe(1);
      expect(mockCronExpression.next).toHaveBeenCalledTimes(2);
      expect(jest.getTimerCount()).toBe(1);
    });

    it("should capture workflow exceptions, log tracking entries, and recover cleanly on the next cycle", async () => {
      const globalErrorSpy = jest.spyOn(Logger, "error").mockImplementation(() => {});
      job = new TestBackgroundJob("FaultyJob", "0 * * * *", true);
      job.shouldFail = true;
      await job.start();
      await jest.advanceTimersByTimeAsync(60000);
      expect(globalErrorSpy).toHaveBeenCalledWith(expect.any(Error));
      expect(job.updateCount).toBe(1);
      job.shouldFail = false;
      await jest.advanceTimersByTimeAsync(100);
      expect(job.updateCount).toBeGreaterThan(1);
    });
  });

  describe("updateNow", () => {
    it("should trigger internal functional processing hooks synchronously upon explicit demand and hand back matching results", async () => {
      job = new TestBackgroundJob("ManualTriggerJob", "0 0 * * *", true);

      const result = await job.updateNow();

      expect(job.updateCount).toBe(1);
      expect(result).toBe("completed");
    });
  });
});
