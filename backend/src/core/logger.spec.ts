import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it, vi } from "vitest";

setupTests();

import { SproutLogger } from "./logger.js";
import { ConsoleLogger } from "@nestjs/common";

describe("SproutLogger", () => {
  it("should construct with default parameters", () => {
    const defaultLogger = new SproutLogger();
    expect(defaultLogger).toBeDefined();
  });

  it("should ignore contexts in contextsToIgnore and format log levels", () => {
    const logger = new SproutLogger("Sprout");

    // Test context ignoring
    let called = false;
    (logger as any).write = () => {
      called = true;
    };

    logger.log("test message", "InstanceLoader");
    expect(called).toBe(false);

    // Call super.log when context is NOT ignored
    logger.log("test message", "CustomContext");

    // Test formatting log levels
    const formattedError = (logger as any).formatMessage("error", "An error occurred", "", "", "[SproutTest]", " +1ms");
    expect(formattedError).toContain("ERROR");
    expect(formattedError).toContain("An error occurred");

    const formattedFatal = (logger as any).formatMessage("fatal", "A fatal error occurred", "", "", "[SproutTest]", " +1ms");
    expect(formattedFatal).toContain("FATAL");

    const formattedWarn = (logger as any).formatMessage("warn", "A warning occurred", "", "", "[SproutTest]", " +1ms");
    expect(formattedWarn).toContain("WARN");
    expect(formattedWarn).toContain("A warning occurred");
  });

  it("should format plain informational messages without a level prefix", () => {
    const logger = new SproutLogger("Sprout");

    const formattedLog = (logger as any).formatMessage("log", "Info message", "", "", "[SproutTest]", " +1ms");

    expect(formattedLog).toContain("Info message");
    expect(formattedLog).not.toContain("[ERROR]");
    expect(formattedLog).not.toContain("[WARN]");
  });

  it("should run the custom log override and skip configured contexts", () => {
    vi.mocked(SproutLogger.prototype.log).mockRestore();

    const logger = new SproutLogger("Sprout");
    const superLog = vi.spyOn(ConsoleLogger.prototype, "log").mockImplementation(() => {});

    logger.log("ignored message", "InstanceLoader");
    logger.log("kept message", "CustomContext");

    expect(superLog).toHaveBeenCalledTimes(1);
    expect(superLog).toHaveBeenCalledWith("kept message", "CustomContext");

    superLog.mockRestore();
    vi.spyOn(SproutLogger.prototype, "log").mockImplementation(() => {});
  });
});
