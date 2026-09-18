import { setupTests } from "@backend/test/helpers";
setupTests();

import { Trim } from "@backend/core/decorator/trim.decorator";

describe("Trim decorator", () => {
  it("should define Trim decorator function", () => {
    expect(Trim).toBeDefined();
  });
});
