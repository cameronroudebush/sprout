import { Configuration } from "@backend/config/core";
import { BackgroundJob } from "@backend/jobs/job-base";
import { Logger } from "@nestjs/common";
import { Job, Queue, Worker } from "bullmq";
import Redis from "ioredis";

/**
 * A horizontally scalable background job base class. Automatically uses L2 cache for distributed task processing if enabled,
 * otherwise falls back to an event-driven local memory queue.
 */
export abstract class DistributedQueueJob<TaskPayload> extends BackgroundJob<any> {
  // L2 properties if enabled from {@link cacheManager}
  private bullQueue?: Queue;
  private bullWorker?: Worker;
  private redisClient?: Redis;

  // L1 fallback if redis is not enabled
  private localQueue: TaskPayload[] = [];
  private isLocalConsuming = false;

  constructor(jobName: string, cronTime: string, enabled: boolean) {
    // Pass 'false' for shouldExecuteImmediately so we can set up the queues first
    super(jobName, cronTime, enabled, false);
    this.logger = new Logger(`job:distributed:${jobName}`);
  }

  /** Intercept the start sequence to initialize queues before the cron runs */
  public override async start() {
    this.logger.log(`Initializing Queue infrastructure...`);

    const isRedisEnabled = Configuration.server.cache.type === "redis";

    if (isRedisEnabled) this.setupBullMQ();
    else this.logger.warn(`L2 cache not configured. Will use L1 Local In-Memory Queue.`);

    // Call the parent start to initialize the cron schedules
    return await super.start();
  }

  /** Initializes BullMQ connections, producers, and workers */
  private setupBullMQ() {
    const redisConfig = Configuration.server.cache.redis;

    this.redisClient = new Redis({
      host: redisConfig.host,
      port: redisConfig.port,
      password: redisConfig.password,
      maxRetriesPerRequest: null,
    });

    // Initialize the Producer
    this.bullQueue = new Queue(this.jobName, { connection: this.redisClient });

    // Initialize the Consumer (Worker)
    this.bullWorker = new Worker(this.jobName, async (job: Job) => await this.processTask(job.data as TaskPayload), {
      connection: this.redisClient,
      concurrency: 5,
    });

    // Global error listener for this worker instance
    this.bullWorker.on("failed", (job, err) => {
      this.logger.error(`Task ${job?.id} failed: ${err.message}`);
    });
  }

  /// Producer, triggers by cron schedule and creates tasks by pushing them to the queue
  protected override async update(): Promise<void> {
    const isRedisEnabled = !!this.redisClient;

    if (isRedisEnabled) {
      const lockKey = `lock:producer:${this.jobName}`;
      const acquired = await this.redisClient!.set(lockKey, "locked", "EX", 60, "NX");

      if (!acquired) {
        this.logger.debug(`Another instance is producing tasks. Running as consumer only.`);
        return; // Exit out, let the winning server queue the tasks
      }
    }

    this.logger.log(`Lock acquired. Generating tasks for ${this.jobName}...`);
    const tasks = await this.generateTasks();

    if (tasks.length > 0) {
      if (isRedisEnabled) {
        // Bulk add to BullMQ for distributed processing
        const bulkJobs = tasks.map((data) => ({ name: "process", data }));
        await this.bullQueue!.addBulk(bulkJobs);
      } else {
        // Add to local array and kickstart the local processor
        this.localQueue.push(...tasks);
        this.startLocalConsumerLoop();
      }
      this.logger.log(`Pushed ${tasks.length} tasks to the queue.`);
    }
  }

  // L1 consumer in the event that L2 is not configured
  private async startLocalConsumerLoop() {
    // Prevent multiple concurrent local loops
    if (this.isLocalConsuming) return;
    this.isLocalConsuming = true;

    // Run only as long as there are items in the queue
    while (this.localQueue.length > 0 && this.isLocalConsuming) {
      try {
        const task = this.localQueue.shift();
        if (task) await this.processTask(task);
      } catch (error) {
        this.logger.error(`Error processing local task: ${(error as Error).message}`);
        // Brief pause on error to prevent infinite crash loops
        await new Promise((resolve) => setTimeout(resolve, 100));
      }
    }

    // Queue is empty, turn off the consumer
    this.isLocalConsuming = false;
  }

  /** Producer. Generate the list of data payloads to be distributed into the queue */
  protected abstract generateTasks(): Promise<TaskPayload[]>;

  /** Consumer. Perform the actual work for a single data payload */
  protected abstract processTask(task: TaskPayload): Promise<any>;
}
