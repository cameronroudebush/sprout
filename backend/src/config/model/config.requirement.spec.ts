import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it, vi } from "vitest";

setupTests();

import { CONFIGURATION_REQUIREMENTS } from "./config.requirement.js";
import { Configuration } from "@backend/config/core.js";

describe("CONFIGURATION_REQUIREMENTS", () => {
  it("should validate and execute fix handlers for configuration requirements", () => {
    const logger = { error: vi.fn(), warn: vi.fn() } as any;

    for (const req of CONFIGURATION_REQUIREMENTS) {
      expect(req.name).toBeDefined();
      const isValid = req.validate();
      expect(typeof isValid).toBe("boolean");
      req.fix(logger);
    }
  });
});
