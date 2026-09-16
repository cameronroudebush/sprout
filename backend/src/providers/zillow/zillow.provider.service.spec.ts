import { setupTests } from "@backend/test/helpers";
setupTests();

import { ZillowProviderService } from "@backend/providers/zillow/zillow.provider.service";

describe("ZillowProviderService", () => {
  let service: ZillowProviderService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new ZillowProviderService();
  });

  describe("config", () => {
    it("should return valid provider configuration object", () => {
      expect(service.config).toBeDefined();
      expect(service.config.dbType).toBe("zillow");
    });
  });
});
