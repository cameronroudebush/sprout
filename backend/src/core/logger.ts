import { TimeZone } from "@backend/config/tz";
import { ConsoleLogger, LogLevel } from "@nestjs/common";

/** A custom logger to use with NestJS to improve our logging capabilities */
export class SproutLogger extends ConsoleLogger {
  static contextsToIgnore = ["InstanceLoader", "RoutesResolver", "RouterExplorer", "NestFactory", "NestApplication"];

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
  ): string {
    const output = this.stringifyMessage(message, logLevel);
    const timestamp = this.getTimestamp();

    // Strip ANSI color codes (e.g., `\x1B[33m`) and brackets from the context
    const rawContext = contextMessage
      .replace(/[\u001b\u009b][[()#;?]*.{0,2}?[0-9;]*.{0,2}?[mGK]/g, "")
      .replace(/[\[\]]/g, "")
      .trim();

    const contextParts = rawContext.split(":").map((part) => `[${part}]`);

    // Customize log level
    let printLevel = "";
    if (logLevel === "error" || logLevel === "warn" || logLevel === "fatal") printLevel = `[${logLevel.toUpperCase()}]`;

    return `[${timestamp}]${contextParts.join("")}${printLevel}: ${output}${timestampDiff}\n`;
  }

  protected override getTimestamp(): string {
    return TimeZone.formatDate(new Date());
  }
}
