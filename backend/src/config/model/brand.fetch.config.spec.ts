import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { BrandFetchConfig } from "@backend/config/model/brand.fetch.config.js";

describe("BrandFetchConfig", () => {
  it("should return null when websiteUrl or clientId is missing", () => {
    const config = new BrandFetchConfig();
    expect(config.getWebsiteIconUrl(null)).toBeNull();
    expect(config.getWebsiteIconUrl("https://example.com")).toBeNull();

    config.clientId = "client-123";
    expect(config.getWebsiteIconUrl(null)).toBeNull();
    expect(config.getWebsiteIconUrl(undefined)).toBeNull();
  });

  it("should construct and generate website icon URL cleaning www and handling paths and invalid URLs", () => {
    const config = new BrandFetchConfig();
    config.clientId = "bf-client-id";

    const iconUrl1 = config.getWebsiteIconUrl("https://www.example.com/path?query=1");
    expect(iconUrl1).toBe("https://cdn.brandfetch.io/domain/example.com/fallback/404/h/64/w/64/icon?c=bf-client-id");

    const iconUrl2 = config.getWebsiteIconUrl("sub.domain.com", 128);
    expect(iconUrl2).toBe("https://cdn.brandfetch.io/domain/sub.domain.com/fallback/404/h/128/w/128/icon?c=bf-client-id");

    // Invalid URL fallback test
    const cleanDomainFn = (config as any).cleanDomain.bind(config);
    expect(cleanDomainFn("http://::invalid::")).toBe("http://::invalid::");
  });
});
