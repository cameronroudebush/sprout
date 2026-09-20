import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it } from "vitest";

setupTests();

import { SproutLogger } from "./logger.js";

describe("SproutLogger", () => {
  it("should format and print log messages", () => {
    const logger = new SproutLogger("TestContext");
    expect(() => logger.log("Test log")).not.toThrow();
    expect(() => logger.error("Test error")).not.toThrow();
    expect(() => logger.warn("Test warn")).not.toThrow();
    expect(() => logger.debug("Test debug")).not.toThrow();
  });
});
