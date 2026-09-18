import { setupTests } from "@backend/test/helpers";
setupTests();

import { CoreModule } from "@backend/core/core.module";

describe("CoreModule", () => {
  it("should define CoreModule class", () => {
    expect(CoreModule).toBeDefined();
  });
});
