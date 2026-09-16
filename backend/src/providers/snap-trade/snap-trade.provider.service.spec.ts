import { setupTests } from "@backend/test/helpers";
setupTests();

import { SnapTradeProviderService } from "@backend/providers/snap-trade/snap-trade.provider.service";

describe("SnapTradeProviderService", () => {
  let service: SnapTradeProviderService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new SnapTradeProviderService();
  });

  describe("config", () => {
    it("should return valid provider configuration object", () => {
      expect(service.config).toBeDefined();
      expect(service.config.dbType).toBe("snapTrade");
    });
  });
});
