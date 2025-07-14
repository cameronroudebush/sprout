import { Configuration } from "@backend/config/core";
import { TimeZone } from "@backend/config/tz";
import chalk from "chalk";
import fs from "fs";
import path from "path";

/** Logger configuration options for our console */
export type LogConfig = {
  /** Header to display after the date of the log */
  header?: string;
  /**
   * If we should prepend the information of who logged this content
   * @default true
   */
  shouldPrependLoggerFile?: boolean;
};

// Clear console when Logger is created
console.clear();
/**
 * This class is used to log our data to the console and wherever else we determine
 */
export class Logger {
  /**
   * The output stream to have a separate log file
   */
  private static logFileStream = fs.createWriteStream(`./${Configuration.appName}.log`, {
    flags: "w",
    autoClose: true,
  });

  /**
   * Gets header data to display with every console log
   */
  static getConsoleLogHeader() {
    return TimeZone.formatDate(new Date());
  }

  /**
   * Console logs the given info with a header
   */
  private static log(info: string | Error, config: LogConfig & { color: chalk.Chalk }) {
    // Set a default log header
    if (config.shouldPrependLoggerFile ?? true) config.header = this.getLoggerFile() + (config.header || "");
    const leadingText = `[${this.getConsoleLogHeader()}]${config.header}`;
    let text: string;
    // Log error stack if available
    if (info instanceof Error) {
      text = `${leadingText}: ${info.stack || info.message}`;
    } else text = `${leadingText}: ${info}`;
    // Show coloring if given
    console.log(config.color(text));
    // Write to log file without coloring
    this.logFileStream.write(`${text}\n`);
  }

  static info(message: string, config?: LogConfig) {
    this.log(message, { ...config, color: chalk.white });
  }

  static success(message: string, config?: LogConfig) {
    this.log(message, { ...config, color: chalk.green });
  }

  static warn(message: string, config?: LogConfig) {
    this.log(message, { ...config, color: chalk.yellow });
  }

  static error(message: string | Error, config?: LogConfig) {
    this.log(message, { ...config, color: chalk.red });
  }

  /** Returns a default header string for a log that considers the location of the previous file call */
  private static getLoggerFile() {
    const err = new Error();
    const originalPrepare = Error.prepareStackTrace;
    Error.prepareStackTrace = (_, stack) => stack;
    const stack = err.stack;
    Error.prepareStackTrace = originalPrepare;
    const filePath: string = (stack as any)[3].getFileName();
    // Adjusted file path up until the source directory
    const filePathToSrcIndex = filePath.indexOf("src");
    const filePathToSrc = filePath.substring(filePathToSrcIndex, filePath.length);
    const splitContent = filePathToSrc.split(path.sep);
    splitContent.shift(); // Remove the first one as it's just going to be src
    // Loop over total directories and return that
    return splitContent.reduce((a, b) => (a += `[${b.replace(".ts", "").replace(".js", "")}]`), "");
  }
}
