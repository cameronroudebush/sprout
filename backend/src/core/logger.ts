import { TimeZone } from "@backend/config/model/tz";
import { ConsoleLogger, LogLevel } from "@nestjs/common";

/** A custom logger to use with NestJS to improve our logging capabilities */
export class SproutLogger extends ConsoleLogger {
  static contextsToIgnore = ["InstanceLoader", "RoutesResolver", "RouterExplorer", "NestFactory", "NestApplication"];

  // Color codes for console display
  private readonly colorCodes = {
    red: "\x1b[31m",
    yellow: "\x1b[33m",
    reset: "\x1b[0m",
    dim: "\x1b[2m",
  };

  /** Applies our selected color to the output */
  private applyColor(text: string, color: keyof typeof this.colorCodes): string {
    return `${this.colorCodes[color]}${text}${this.colorCodes.reset}`;
  }

  override log(...args: any[]): void {
    // Ignore some logging contexts that are specific to NestJS
    const context = args[1] as string;
    if (SproutLogger.contextsToIgnore.includes(context)) return;

    super.log.apply(this, args as any);
  }

  protected override formatMessage(
    logLevel: LogLevel,
    message: unknown,
    _pidMessage: string,
    _formattedLogLevel: string,
    contextMessage: string,
    timestampDiff: string,
  ) {
    let output = this.stringifyMessage(message, logLevel);
    const timestamp = this.getTimestamp();

    // Strip ANSI color codes (e.g., `\x1B[33m`) and brackets from the context
    const rawContext = contextMessage
      .replace(/[\u001b\u009b][[()#;?]*.{0,2}?[0-9;]*.{0,2}?[mGK]/g, "")
      .replace(/[\[\]]/g, "")
      .trim();

    const contextParts = rawContext.split(":").map((part) => `[${part}]`);

    // Customize log level
    let printLevel = "";
    if (logLevel === "error" || logLevel === "fatal") {
      output = this.applyColor(output, "red");
      printLevel = `[${this.applyColor(logLevel.toUpperCase(), "red")}]`;
    } else if (logLevel === "warn") {
      printLevel = `[${this.applyColor(logLevel.toUpperCase(), "yellow")}]`;
    }

    return `[${timestamp}]${contextParts.join("")}${printLevel}: ${output}${timestampDiff}\n`;
  }

  protected override getTimestamp(): string {
    return TimeZone.formatDate(new Date());
  }
}
