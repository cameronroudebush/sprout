import { Configuration } from "@backend/config/core";
import { TimeZone } from "@backend/config/model/tz";
import { Logger } from "@nestjs/common";
import CronExpressionParser, { CronExpression } from "cron-parser";
import { addMinutes } from "date-fns";

/** A generic class that lets us create background jobs based on a cronjob timeframe. Intended to be used as an extension. */
export abstract class BackgroundJob<T extends any = any> {
  protected logger: Logger;
  private interval!: CronExpression;

  /**
   * Creates an instance of a background job
   * @param cronTime The cronjob formatted time of when to run this job
   * @param enabled Normally controlled by a configuration property, tracks if this job should execute in the background or any other functionality.
   * @param shouldExecuteImmediately If we should immediately fire the task, else waits for the next cron interval. Only fires if this job is enabled.
   */
  constructor(
    public jobName: string,
    private cronTime: string,
    private enabled: boolean,
    private shouldExecuteImmediately = false,
  ) {
    this.logger = new Logger(`job:${jobName}`);
    this.interval = CronExpressionParser.parse(this.cronTime, { tz: TimeZone.timeZone });
  }

  /**
   * Starts the background job listeners
   */
  public async start() {
    if (Configuration.isRunningScript) return this; // Don't do anything on script runs
    // If this job is not enabled, don't use it.
    if (!this.enabled) {
      this.logger.warn(`Job is disabled. This job will only run as manually requested.`);
    } else {
      if (this.shouldExecuteImmediately) {
        this.logger.log(`Job is requesting to run immediately. Executing...`);
        await this.update();
      }
      this.logger.log(`Initializing background job of: ${this.cronTime}`);
      this.scheduleNextUpdate();
    }
    return this;
  }

  /**
   * Schedules the next update based on the cronjob time
   *
   * @param fromFailed If a job failed and we are auto-retrying after some time, this indicates this was from a failed job.
   */
  private scheduleNextUpdate(nextExecutionDate = this.interval.next().toDate(), fromFailed = false) {
    const timeUntilNextExecution = nextExecutionDate.getTime() - Date.now();
    this.logger.log(`Next update time: ${TimeZone.formatDate(nextExecutionDate)}`);
    setTimeout(async () => {
      try {
        await this.update();
      } catch (e) {
        Logger.error(e as Error);
        // Schedule a sooner one, just in case of a failure out of our control, which is most of them.
        const soonerNextExecution = addMinutes(new Date(), Configuration.server.jobs.autoRetryTime);
        this.scheduleNextUpdate(soonerNextExecution, true);
      }

      // Schedule our next update, only if this isn't from a failure that is running sooner than expected.
      if (!fromFailed) this.scheduleNextUpdate();
    }, timeUntilNextExecution);
  }

  /** Executes an update right now */
  public async updateNow() {
    return await this.update();
  }

  /** Performs the update for this background job and returns it's result */
  protected abstract update(): Promise<T>;
}
