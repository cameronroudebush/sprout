import { Configuration } from "@backend/config/core";
import { TimeZone } from "@backend/config/tz";
import CronExpressionParser, { CronExpression } from "cron-parser";
import { addMinutes } from "date-fns";
import { LogConfig, Logger } from "../logger";

/** A generic class that lets us create background jobs based on a cronjob timeframe. Intended to be used as an extension. */
export abstract class BackgroundJob<T extends any> {
  private interval: CronExpression;

  /** Gets some extra configuration for the logger to display better messages for these jobs. */
  protected get logConfig(): LogConfig {
    return { header: `[jobs][${this.jobName}]`, shouldPrependLoggerFile: false };
  }

  /**
   * Creates an instance of a background job
   * @param cronTime The cronjob formatted time of when to run this job
   */
  constructor(
    public jobName: string,
    private cronTime: string,
  ) {
    Logger.info(`Initializing background job of: ${this.cronTime}`, this.logConfig);
    this.interval = CronExpressionParser.parse(this.cronTime, { tz: TimeZone.timeZone });
  }

  /**
   * Starts the background job listeners
   * @param shouldExecuteImmediately If we should immediately fire the task, else waits for the next cron interval
   */
  public async start(shouldExecuteImmediately = false) {
    // Perform update if requested, else schedule the next update
    if (shouldExecuteImmediately) await this.update();
    this.scheduleNextUpdate();
    return this;
  }

  /**
   * Schedules the next update based on the cronjob time
   *
   * @param fromFailed If a job failed and we are auto-retrying after some time, this indicates this was from a failed job.
   */
  private scheduleNextUpdate(nextExecutionDate = this.interval.next().toDate(), fromFailed = false) {
    const timeUntilNextExecution = nextExecutionDate.getTime() - Date.now();
    Logger.info(`Next update time: ${TimeZone.formatDate(nextExecutionDate)}`, this.logConfig);
    setTimeout(async () => {
      try {
        await this.update();
      } catch (e) {
        Logger.error(e as Error);
        // Schedule a sooner one, just in case of a failure out of our control, which is most of them.
        const soonerNextExecution = addMinutes(new Date(), Configuration.server.jobs.autoRetryTime);
        this.scheduleNextUpdate(soonerNextExecution, true);

        // Schedule our next update, only if this isn't from a failure "nextUpdate"
        if (!fromFailed) this.scheduleNextUpdate();
      }
    }, timeUntilNextExecution);
  }

  /** Executes an update right now */
  public async updateNow() {
    return await this.update();
  }

  /** Performs the update for this background job and returns it's result */
  protected abstract update(): Promise<T>;
}
