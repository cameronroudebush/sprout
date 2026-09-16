import { setupTests } from "@backend/test/helpers";
setupTests();

import { PlaidProviderService } from "@backend/providers/plaid/plaid.provider.service";

describe("PlaidProviderService", () => {
  let service: PlaidProviderService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new PlaidProviderService();
  });

  describe("config", () => {
    it("should return valid provider configuration object", () => {
      expect(service.config).toBeDefined();
      expect(service.config.dbType).toBe("plaid");
    });
  });
});
