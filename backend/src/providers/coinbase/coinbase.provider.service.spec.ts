import { setupTests } from "@backend/test/helpers";
setupTests();

import { CoinbaseProviderService } from "@backend/providers/coinbase/coinbase.provider.service";

describe("CoinbaseProviderService", () => {
  let service: CoinbaseProviderService;
  let cacheManager: any;

  beforeEach(() => {
    vi.clearAllMocks();
    cacheManager = {
      get: vi.fn(),
      set: vi.fn(),
    };
    service = new CoinbaseProviderService(cacheManager);
  });

  describe("config", () => {
    it("should return valid provider configuration object", () => {
      expect(service.config).toBeDefined();
      expect(service.config.dbType).toBe("coinbase");
    });
  });
});
