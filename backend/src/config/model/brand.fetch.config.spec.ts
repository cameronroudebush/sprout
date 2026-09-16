import { setupTests } from "@backend/test/helpers";
setupTests();

import { BrandFetchConfig } from "@backend/config/model/brand.fetch.config";

describe("BrandFetchConfig", () => {
  it("should construct and generate website icon URL", () => {
    const config = new BrandFetchConfig();
    config.clientId = "bf-client-id";

    const iconUrl = config.getWebsiteIconUrl("https://example.com");
    expect(iconUrl).toContain("example.com");
  });
});
