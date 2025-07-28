import { TimeZone } from "@backend/config/tz";
import CronExpressionParser, { CronExpression } from "cron-parser";
import { LogConfig, Logger } from "./logger";

/** A generic class that lets us create background jobs based on a cronjob timeframe. Intended to be used as an extension. */
export abstract class BackgroundJob<T extends any> {
  private interval: CronExpression;

  /** Gets some extra configuration for the logger to display better messages for these jobs. */
  protected get logConfig(): LogConfig {
    return { header: `[${this.jobName}]` };
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
    if (shouldExecuteImmediately) this.update();
    this.scheduleNextUpdate();
  }

  /** Schedules the next update based on the cronjob time */
  private scheduleNextUpdate() {
    const nextExecutionDate = this.interval.next().toDate();
    const timeUntilNextExecution = nextExecutionDate.getTime() - Date.now();
    Logger.info(`Next update time: ${TimeZone.formatDate(nextExecutionDate)}`, this.logConfig);
    setTimeout(async () => {
      await this.update();
      this.scheduleNextUpdate();
    }, timeUntilNextExecution);
  }

  /** Executes an update right now */
  public async updateNow() {
    return await this.update();
  }

  /** Performs the update for this background job and returns it's result */
  protected abstract update(): Promise<T>;
}
