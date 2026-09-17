import { setupTests } from "@backend/test/helpers";
setupTests();

import { ProviderModule } from "@backend/providers/provider.module";

describe("ProviderModule", () => {
  it("should define module class", () => {
    expect(ProviderModule).toBeDefined();
  });
});
