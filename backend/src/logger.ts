import chalk from "chalk";
import fs from "fs";
import { name } from "../package.json";

// Clear console when Logger is created
console.clear();
/**
 * This class is used to log our data to the console and wherever else we determine
 */
export class Logger {
  /**
   * The output stream to have a separate log file
   */
  private static logFileStream = fs.createWriteStream(`./${name}.log`, {
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
  static log(info: string, coloring?: chalk.Chalk, showHeader = true) {
    // Show header if wanted
    let text = "";
    if (showHeader) text = `${this.getConsoleLogHeader()}: ${info}`;
    else text = `${info}`;
    // Show coloring if given
    if (coloring) console.log(coloring(text));
    else console.log(text);
    // Write to log file
    this.logFileStream.write(`${text}\n`);
  }
}
