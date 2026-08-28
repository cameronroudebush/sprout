import { setupTests } from "@backend/test/helpers";
setupTests();

import { CoreController } from "@backend/core/core.controller";

describe("CoreController", () => {
  let controller: CoreController;

  beforeEach(() => {
    controller = new CoreController();
  });

  describe("heartbeat", () => {
    it("should return heartbeat message", async () => {
      const result = await controller.heartbeat();
      expect(result).toBe("Sprout is alive!");
    });
  });
});
