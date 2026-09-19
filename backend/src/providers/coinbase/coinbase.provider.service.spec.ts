import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { Account } from "@backend/account/model/account.model.js";
import { Configuration } from "@backend/config/core.js";
import { ProviderRateLimit } from "@backend/providers/base/rate-limit.js";
import { CoinbaseProviderService } from "@backend/providers/coinbase/coinbase.provider.service.js";
import { TestEntities } from "@backend/test/entities.js";
import { User } from "@backend/user/model/user.model.js";
import { BadRequestException, NotImplementedException } from "@nestjs/common";
import axios from "axios";
import { sign } from "jsonwebtoken";

vi.mock("jsonwebtoken", () => ({
  sign: vi.fn().mockReturnValue("mocked-jwt-token"),
  default: {
    sign: vi.fn().mockReturnValue("mocked-jwt-token"),
  },
}));

describe("CoinbaseProviderService", () => {
  let service: CoinbaseProviderService;
  let cacheManager: any;
  let user: User;

  beforeEach(() => {
    vi.clearAllMocks();
    cacheManager = {
      get: vi.fn(),
      set: vi.fn().mockResolvedValue(undefined),
    };
    user = TestEntities.user;
    user.config.coinbaseApiKey = "test-key";
    user.config.coinbaseApiKeyName = "test-key-name";

    vi.spyOn(ProviderRateLimit.prototype, "incrementOrError").mockResolvedValue(undefined);

    service = new CoinbaseProviderService(cacheManager);
  });

  describe("isAvailable & generateLinkToken", () => {
    it("should instantiate with or without provider config", () => {
      Configuration.providers.coinbase.clientId = "client-id";
      Configuration.providers.coinbase.consumerKey = "consumer-key";

      const configuredService = new CoinbaseProviderService(cacheManager);
      expect(configuredService.config).toBeDefined();

      Configuration.providers.coinbase.clientId = "";
    });

    it("should return availability status", async () => {
      expect(await service.isAvailable(user)).toBe(true);

      user.config.coinbaseApiKey = "";
      expect(await service.isAvailable(user)).toBe(false);
    });

    it("should throw NotImplementedException in generateLinkToken", async () => {
      await expect(service.generateLinkToken()).rejects.toThrow(NotImplementedException);
    });
  });

  describe("performExchange and performSync", () => {
    it("should throw BadRequestException in performExchange if keys are missing", async () => {
      user.config.coinbaseApiKey = "";
      await expect((service as unknown as { performExchange: (u: User) => Promise<unknown> }).performExchange(user)).rejects.toThrow(BadRequestException);
    });

    it("should performExchange with active accounts", async () => {
      vi.spyOn(service as unknown as { fetchCoinbaseData: () => Promise<unknown[]> }, "fetchCoinbaseData").mockResolvedValue([
        { id: "acc-1", name: "BTC Wallet", balance: { amount: "1.5", currency: "BTC" } },
        { id: "acc-2", name: "ETH Wallet", balance: { amount: "0", currency: "ETH" } },
      ]);
      vi.spyOn(service as unknown as { getUsdExchangeRates: () => Promise<Record<string, number>> }, "getUsdExchangeRates").mockResolvedValue({ BTC: 50000 });

      const results = await (service as unknown as { performExchange: (u: User) => Promise<Array<{ institutionName: string }>> }).performExchange(user);
      expect(results.length).toBe(1);
      expect(results[0]?.institutionName).toBe("Coinbase");
    });

    it("should performSync with existing account", async () => {
      const existingAccount = TestEntities.account;
      existingAccount.providerAccountId = "coinbase-primary-wallet";
      vi.spyOn(Account, "find").mockResolvedValue([existingAccount]);

      vi.spyOn(service as unknown as { fetchCoinbaseData: () => Promise<unknown[]> }, "fetchCoinbaseData").mockResolvedValue([
        { id: "acc-1", name: "BTC Wallet", balance: { amount: "2.0", currency: "BTC" } },
      ]);
      vi.spyOn(service as unknown as { getUsdExchangeRates: () => Promise<Record<string, number>> }, "getUsdExchangeRates").mockResolvedValue({ BTC: 60000 });

      const syncRes = await (
        service as unknown as { performSync: (u: User, a: undefined, ao: boolean) => Promise<Array<{ holdings: unknown[] }>> }
      ).performSync(user, undefined, false);
      expect(syncRes.length).toBe(1);
      expect(syncRes[0]?.holdings.length).toBe(1);
    });

    it("should return empty array in performSync if user unavailable or no existing account", async () => {
      user.config.coinbaseApiKey = "";
      const res1 = await (service as unknown as { performSync: (u: User, a: undefined, ao: boolean) => Promise<unknown[]> }).performSync(
        user,
        undefined,
        false,
      );
      expect(res1).toEqual([]);

      user.config.coinbaseApiKey = "key";
      vi.spyOn(Account, "find").mockResolvedValue([]);
      const res2 = await (service as unknown as { performSync: (u: User, a: undefined, ao: boolean) => Promise<unknown[]> }).performSync(
        user,
        undefined,
        false,
      );
      expect(res2).toEqual([]);
    });
  });

  describe("getUsdExchangeRates & fetchCoinbaseData", () => {
    it("should return cached rates if available or fetch from Coinbase API", async () => {
      cacheManager.get.mockResolvedValue({ BTC: 50000 });
      const ratesCached = await (service as unknown as { getUsdExchangeRates: () => Promise<Record<string, number>> }).getUsdExchangeRates();
      expect(ratesCached.BTC).toBe(50000);

      cacheManager.get.mockResolvedValue(null);
      vi.spyOn(axios, "get").mockResolvedValue({
        data: { data: { rates: { BTC: "0.00002" } } },
      } as any);

      const ratesFresh = await (service as unknown as { getUsdExchangeRates: () => Promise<Record<string, number>> }).getUsdExchangeRates();
      expect(ratesFresh.BTC).toBeCloseTo(50000, 2);
      expect(cacheManager.set).toHaveBeenCalled();
    });

    it("should handle error in getUsdExchangeRates", async () => {
      cacheManager.get.mockResolvedValue(null);
      vi.spyOn(axios, "get").mockRejectedValue(new Error("Network error"));

      const rates = await (service as unknown as { getUsdExchangeRates: () => Promise<Record<string, number>> }).getUsdExchangeRates();
      expect(rates).toEqual({});
    });

    it("should fetchCoinbaseData with pagination and handles errors", async () => {
      vi.spyOn(axios, "get")
        .mockResolvedValueOnce({
          data: {
            accounts: [{ id: "acc-1" }],
            pagination: { next_starting_after: "after-1" },
          },
        } as any)
        .mockResolvedValueOnce({
          data: {
            accounts: [{ id: "acc-2" }],
            pagination: {},
          },
        } as any);

      const data = await (service as unknown as { fetchCoinbaseData: (u: User, r: string) => Promise<unknown[]> }).fetchCoinbaseData(user, "accounts");
      expect(data.length).toBe(2);

      vi.spyOn(axios, "get").mockRejectedValue(new Error("API error"));
      const errData = await (service as unknown as { fetchCoinbaseData: (u: User, r: string) => Promise<unknown[]> }).fetchCoinbaseData(user, "accounts");
      expect(errData).toEqual([]);
    });

    it("should test helper hooks", async () => {
      expect((service as unknown as { extractProviderAccountId: (r: { id: string }) => string }).extractProviderAccountId({ id: "wallet-1" })).toBe("wallet-1");
      expect((service as unknown as { extractAccountName: (r: { name: string }) => string }).extractAccountName({ name: "Primary" })).toBe("Primary");
      expect(await (service as unknown as { getInstitutionAssetsForUser: () => Promise<undefined[]> }).getInstitutionAssetsForUser()).toEqual([undefined]);
    });
  });
});
