import { setupTests } from "@backend/test/helpers";
setupTests();

import { SproutLogger } from "@backend/core/logger";

describe("SproutLogger", () => {
  it("should format log messages with context and project name", () => {
    const logger = new SproutLogger("SproutApp");
    const spy = jest.spyOn(process.stdout, "write").mockImplementation(() => true);

    logger.log("Test log message", "TestContext");

    expect(spy).toHaveBeenCalled();
    spy.mockRestore();
  });
});
