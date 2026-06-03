import { setupTests } from "@backend/test/helpers";
setupTests();

import { Configuration } from "@backend/config/core";
import { BackgroundJob } from "@backend/jobs/job-base";
import { DistributedQueueJob } from "@backend/jobs/job-distributed-base";
import { Queue, Worker } from "bullmq";
import Redis from "ioredis";

jest.mock("bullmq", () => {
  return {
    Queue: jest.fn().mockImplementation(() => ({
      addBulk: jest.fn().mockResolvedValue([]),
    })),
    Worker: jest.fn().mockImplementation((_name, _processor, _opts) => {
      const listeners: Record<string, Function> = {};
      return {
        on: jest.fn().mockImplementation((event, cb) => {
          listeners[event] = cb;
          return this;
        }),
        emitFailed: (job: any, err: any) => {
          if (listeners["failed"]) listeners["failed"](job, err);
        },
      };
    }),
  };
});

jest.mock("ioredis", () => {
  return jest.fn().mockImplementation(() => ({
    set: jest.fn(),
  }));
});

class TestDistributedQueueJob extends DistributedQueueJob<string> {
  public mockTasks: string[] = [];
  public processedTasks: string[] = [];
  public processFailOn: string | null = null;

  protected async generateTasks(): Promise<string[]> {
    return this.mockTasks;
  }

  protected async processTask(task: string): Promise<any> {
    this.processedTasks.push(task);
    if (this.processFailOn === task) {
      throw new Error(`Intentional failure for ${task}`);
    }
  }

  public async triggerUpdate(): Promise<void> {
    return await this.update();
  }

  public getLocalQueue() {
    return (this as any).localQueue;
  }

  public setIsLocalConsuming(val: boolean) {
    (this as any).isLocalConsuming = val;
  }
}

describe("DistributedQueueJob", () => {
  let testJob: TestDistributedQueueJob;
  let superStartSpy: jest.SpyInstance;

  beforeEach(() => {
    jest.clearAllMocks();
    Configuration.server.cache.type = "local";
    Configuration.server.cache.redis = { host: "localhost", port: 6379, password: "pass" } as any;

    superStartSpy = jest.spyOn(BackgroundJob.prototype, "start").mockResolvedValue(undefined as any);
    testJob = new TestDistributedQueueJob("test-job", "* * * * *", true);
  });

  describe("start and Initialization", () => {
    it("should initialize with local memory parameters when cache type is memory", async () => {
      const warnSpy = jest.spyOn((testJob as any).logger, "warn");

      await testJob.start();

      expect(warnSpy).toHaveBeenCalledWith("L2 cache not configured. Will use L1 Local In-Memory Queue.");
      expect(superStartSpy).toHaveBeenCalled();
      expect(Queue).not.toHaveBeenCalled();
      expect(Worker).not.toHaveBeenCalled();
    });

    it("should initialize BullMQ components when cache type is configured to redis", async () => {
      Configuration.server.cache.type = "redis";
      const logSpy = jest.spyOn((testJob as any).logger, "log");

      await testJob.start();

      expect(logSpy).toHaveBeenCalledWith("Initializing Queue infrastructure...");
      expect(Redis).toHaveBeenCalledWith({
        host: "localhost",
        port: 6379,
        password: "pass",
        maxRetriesPerRequest: null,
      });
      expect(Queue).toHaveBeenCalledWith("test-job", expect.any(Object));
      expect(Worker).toHaveBeenCalledWith("test-job", expect.any(Function), expect.any(Object));
      expect(superStartSpy).toHaveBeenCalled();
    });

    it("should correctly handle and log failures triggered from BullMQ worker listeners", async () => {
      Configuration.server.cache.type = "redis";
      const errorSpy = jest.spyOn((testJob as any).logger, "error");

      await testJob.start();

      const mockWorkerInstance = (Worker as unknown as jest.Mock).mock.results[0]!.value;
      mockWorkerInstance.emitFailed({ id: "job-101" }, { message: "Connection lost" });

      expect(errorSpy).toHaveBeenCalledWith("Task job-101 failed: Connection lost");
    });
  });

  describe("update (Producer Engine)", () => {
    it("should generate and submit tasks to BullMQ when redis cache context is operational and lock is successfully acquired", async () => {
      Configuration.server.cache.type = "redis";
      await testJob.start();

      const mockRedisInstance = (Redis as unknown as jest.Mock).mock.results[0]!.value;
      mockRedisInstance.set.mockResolvedValue("OK");

      const mockQueueInstance = (Queue as unknown as jest.Mock).mock.results[0]!.value;
      testJob.mockTasks = ["task-alpha", "task-beta"];

      await testJob.triggerUpdate();

      expect(mockRedisInstance.set).toHaveBeenCalledWith("lock:producer:test-job", "locked", "EX", 60, "NX");
      expect(mockQueueInstance.addBulk).toHaveBeenCalledWith([
        { name: "process", data: "task-alpha" },
        { name: "process", data: "task-beta" },
      ]);
    });

    it("should exit execution paths early and skip distribution cycles if producer lock acquisition returns falsy values", async () => {
      Configuration.server.cache.type = "redis";
      await testJob.start();

      const mockRedisInstance = (Redis as unknown as jest.Mock).mock.results[0]!.value;
      mockRedisInstance.set.mockResolvedValue(null);

      const debugSpy = jest.spyOn((testJob as any).logger, "debug");
      testJob.mockTasks = ["task-gamma"];

      await testJob.triggerUpdate();

      expect(debugSpy).toHaveBeenCalledWith("Another instance is producing tasks. Running as consumer only.");
      const mockQueueInstance = (Queue as unknown as jest.Mock).mock.results[0]!.value;
      expect(mockQueueInstance.addBulk).not.toHaveBeenCalled();
    });

    it("should route generated entities straight into fallback local structures when local execution loops operate", async () => {
      testJob.mockTasks = ["local-1", "local-2"];
      const logSpy = jest.spyOn((testJob as any).logger, "log");

      await testJob.triggerUpdate();

      expect(logSpy).toHaveBeenCalledWith("Pushed 2 tasks to the queue.");
      expect(testJob.processedTasks).toEqual(["local-1", "local-2"]);
      expect(testJob.getLocalQueue().length).toBe(0);
    });

    it("should skip pushing operations and bypass messaging logging paths if task generation maps out zero records", async () => {
      testJob.mockTasks = [];
      const logSpy = jest.spyOn((testJob as any).logger, "log");

      await testJob.triggerUpdate();

      expect(logSpy).not.toHaveBeenCalledWith(expect.stringContaining("Pushed"));
      expect(testJob.processedTasks.length).toBe(0);
    });
  });

  describe("startLocalConsumerLoop (L1 Mechanics)", () => {
    it("should prevent concurrent consumer activation loops if consumer processes are already running", async () => {
      testJob.setIsLocalConsuming(true);
      testJob.getLocalQueue().push("delayed-task");

      await (testJob as any).startLocalConsumerLoop();

      expect(testJob.processedTasks.length).toBe(0);
      expect(testJob.getLocalQueue().length).toBe(1);
    });

    it("should capture local consumer exceptions and process sequential entries smoothly after momentary recovery delays", async () => {
      jest.useFakeTimers();

      testJob.mockTasks = ["fail-task", "success-task"];
      testJob.processFailOn = "fail-task";

      const errorSpy = jest.spyOn((testJob as any).logger, "error");

      const updatePromise = testJob.triggerUpdate();

      await Promise.resolve();

      await jest.runOnlyPendingTimersAsync();

      await updatePromise;

      expect(errorSpy).toHaveBeenCalledWith("Error processing local task: Intentional failure for fail-task");
      expect(testJob.processedTasks).toEqual(["fail-task", "success-task"]);
      expect(testJob.getLocalQueue().length).toBe(0);

      jest.useRealTimers();
    });
  });
});
