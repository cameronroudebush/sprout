import { setupTests } from "@backend/test/helpers";
setupTests();

import { CurrentUser } from "@backend/core/decorator/current-user.decorator";

describe("CurrentUser decorator", () => {
  it("should define CurrentUser decorator", () => {
    expect(CurrentUser).toBeDefined();
  });
});
