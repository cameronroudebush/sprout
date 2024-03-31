import chalk from "chalk";
import fs from "fs";
import path from "path";
import { Configuration } from "./config/core";

type LogConfig = { header?: string };

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
    return new Date().toISOString();
  }

  /**
   * Console logs the given info with a header
   */
  private static log(info: string, config: LogConfig & { color: chalk.Chalk }) {
    // Set a default log header
    if (!config.header) config.header = this.getLoggerFile();
    // Show header if wanted
    let text = `[${this.getConsoleLogHeader()}]${config.header}: ${info}`;
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

  static error(message: string, config?: LogConfig) {
    this.log(message, { ...config, color: chalk.red });
  }

  /** Returns a default header string for a log that considers the location of the previous file call */
  private static getLoggerFile() {
    const err = new Error();
    Error.prepareStackTrace = (_, stack) => stack;
    const stack = err.stack;
    Error.prepareStackTrace = undefined;
    const filePath: string = (stack as any)[3].getFileName();
    const splitContent = filePath.split(path.sep);
    return `[${splitContent[splitContent.length - 2]}][${splitContent[splitContent.length - 1]?.replace(".ts", "")}]`;
  }
}
