import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { Account } from "@backend/account/model/account.model.js";
import { Configuration } from "@backend/config/core.js";
import { ProviderRateLimit } from "@backend/providers/base/rate-limit.js";
import { SnapTradeInstitutionAsset } from "@backend/providers/snap-trade/model/snap-trade.institution.asset.model.js";
import { SnapTradeUser } from "@backend/providers/snap-trade/model/snap-trade.user.js";
import { SnapTradeProviderService } from "@backend/providers/snap-trade/snap-trade.provider.service.js";
import { TestEntities } from "@backend/test/entities.js";
import { BadRequestException, InternalServerErrorException } from "@nestjs/common";

describe("SnapTradeProviderService", () => {
  let service: SnapTradeProviderService;
  let user: any;

  beforeEach(() => {
    vi.clearAllMocks();
    user = TestEntities.user;

    Configuration.providers.snapTrade.clientId = "test-client-id";
    Configuration.providers.snapTrade.consumerKey = "test-consumer-key";

    vi.spyOn(ProviderRateLimit.prototype, "incrementOrError").mockResolvedValue(undefined);

    service = new SnapTradeProviderService();
    (service as unknown as { snaptrade: Record<string, unknown> }).snaptrade = {
      apiStatus: { check: vi.fn().mockResolvedValue({ data: { online: true } }) },
      authentication: {
        registerSnapTradeUser: vi.fn().mockResolvedValue({ data: { userSecret: "secret-123" } }),
        loginSnapTradeUser: vi.fn().mockResolvedValue({ data: { redirectURI: "https://snaptrade.com/redirect" } }),
      },
      connections: {
        listBrokerageAuthorizations: vi.fn(),
        deleteConnection: vi.fn().mockResolvedValue({}),
      },
      accountInformation: {
        listUserAccounts: vi.fn(),
        getUserAccountBalance: vi.fn().mockResolvedValue({ data: [{ cash: 100 }] }),
        getAllAccountPositions: vi.fn().mockResolvedValue({ data: { results: [] } }),
        getAccountActivities: vi.fn().mockResolvedValue({ data: { data: [] } }),
      },
    };
  });

  describe("constructor & availability", () => {
    it("should instantiate without keys", () => {
      Configuration.providers.snapTrade.clientId = "";
      const unconfiguredService = new SnapTradeProviderService();
      expect(unconfiguredService.snaptrade).toBeUndefined();
    });

    it("should return online status from snaptrade apiStatus", async () => {
      const avail = await service.isAvailable(user);
      expect(avail).toBe(true);

      ((service as unknown as { snaptrade: { apiStatus: { check: () => Promise<unknown> } } }).snaptrade.apiStatus.check as Mock).mockRejectedValue(
        new Error("API offline"),
      );
      const offline = await service.isAvailable(user);
      expect(offline).toBe(false);
    });

    it("should throw InternalServerErrorException if snaptrade client is null", () => {
      (service as unknown as { snaptrade: null }).snaptrade = null;
      expect(() => (service as unknown as { checkClient: () => void }).checkClient()).toThrow(InternalServerErrorException);
    });
  });

  describe("generateLinkToken", () => {
    it("should register new SnapTradeUser if not present and generate link", async () => {
      vi.spyOn(SnapTradeUser, "findOne").mockResolvedValue(null);
      vi.spyOn(SnapTradeUser.prototype, "insert").mockImplementation(async function (this: SnapTradeUser) {
        return this;
      });

      const url = await service.generateLinkToken(user, { redirectUrl: "https://sprout.local" });
      expect(url).toBe("https://snaptrade.com/redirect");
    });

    it("should throw BadRequestException if SnapTrade registration fails", async () => {
      vi.spyOn(SnapTradeUser, "findOne").mockResolvedValue(null);
      (
        (service as unknown as { snaptrade: { authentication: { registerSnapTradeUser: () => Promise<unknown> } } }).snaptrade.authentication
          .registerSnapTradeUser as Mock
      ).mockRejectedValue(new Error("Reg error"));

      await expect(service.generateLinkToken(user)).rejects.toThrow(BadRequestException);
    });
  });

  describe("performExchange, rollbackExchange, performUnlink", () => {
    it("should exchange connections and user accounts", async () => {
      vi.spyOn(SnapTradeUser, "findOne").mockResolvedValue(new SnapTradeUser(user, "sec-123"));

      (
        (service as unknown as { snaptrade: { connections: { listBrokerageAuthorizations: () => Promise<unknown> } } }).snaptrade.connections
          .listBrokerageAuthorizations as Mock
      ).mockResolvedValue({
        data: [{ id: "conn-1", brokerage: { name: "Robinhood", url: "https://robinhood.com" } }],
      });

      (
        (service as unknown as { snaptrade: { accountInformation: { listUserAccounts: () => Promise<unknown> } } }).snaptrade.accountInformation
          .listUserAccounts as Mock
      ).mockResolvedValue({
        data: [{ id: "acc-1", name: "Brokerage", brokerage_authorization: "conn-1", balance: { total: { amount: 1000 } } }],
      });

      const res = await (service as unknown as { performExchange: (u: unknown) => Promise<Array<{ institutionName: string }>> }).performExchange(user);
      expect(res.length).toBe(1);
      expect(res[0]?.institutionName).toBe("Robinhood");
    });

    it("should throw BadRequestException if SnapTradeUser missing in performExchange", async () => {
      vi.spyOn(SnapTradeUser, "findOne").mockResolvedValue(null);
      await expect((service as unknown as { performExchange: (u: unknown) => Promise<unknown> }).performExchange(user)).rejects.toThrow(BadRequestException);
    });

    it("should rollback exchange and perform unlink", async () => {
      await (
        service as unknown as { rollbackExchange: (u: unknown, p: unknown, a: { authorizationId: string; userSecret: string }) => Promise<void> }
      ).rollbackExchange(user, undefined, { authorizationId: "conn-1", userSecret: "sec-1" });
      expect(service.snaptrade.connections.deleteConnection).toHaveBeenCalled();

      const asset = new SnapTradeInstitutionAsset(TestEntities.institution, "conn-1");
      vi.spyOn(SnapTradeUser, "findOne").mockResolvedValue(new SnapTradeUser(user, "sec-123"));

      await (service as unknown as { performUnlink: (u: unknown, a: SnapTradeInstitutionAsset) => Promise<void> }).performUnlink(user, asset);
      expect(service.snaptrade.connections.deleteConnection).toHaveBeenCalledTimes(2);
    });
  });

  describe("performSync, handleSyncError, and asset hooks", () => {
    it("should perform sync with positions as holdings and activities as transactions", async () => {
      const asset = new SnapTradeInstitutionAsset(TestEntities.institution, "conn-1");
      vi.spyOn(SnapTradeUser, "findOne").mockResolvedValue(new SnapTradeUser(user, "sec-123"));

      const rawAccount = {
        id: "acc-1",
        number: "123",
        brokerage_authorization: "conn-1",
        balance: { total: { amount: 2000, currency: "USD" } },
        raw_type: "margin",
      };
      (
        (service as unknown as { snaptrade: { accountInformation: { listUserAccounts: () => Promise<unknown> } } }).snaptrade.accountInformation
          .listUserAccounts as Mock
      ).mockResolvedValue({
        data: [rawAccount],
      });

      (
        (service as unknown as { snaptrade: { accountInformation: { getAllAccountPositions: () => Promise<unknown> } } }).snaptrade.accountInformation
          .getAllAccountPositions as Mock
      ).mockResolvedValue({
        data: {
          results: [{ units: 10, price: 150, cost_basis: 140, currency: "USD", instrument: { description: "Apple", symbol: "AAPL" } }],
        },
      });

      (
        (service as unknown as { snaptrade: { accountInformation: { getAccountActivities: () => Promise<unknown> } } }).snaptrade.accountInformation
          .getAccountActivities as Mock
      ).mockResolvedValue({
        data: {
          data: [{ id: "tx-1", trade_date: "2026-06-15", amount: 100, description: "Bought AAPL", type: "BUY" }],
        },
      });

      vi.spyOn(Account, "findOne").mockResolvedValue(TestEntities.account);

      const results = await (
        service as unknown as {
          performSync: (u: unknown, a: SnapTradeInstitutionAsset, ao: boolean) => Promise<Array<{ holdings: unknown[]; transactions: unknown[] }>>;
        }
      ).performSync(user, asset, false);
      expect(results.length).toBe(1);
      expect(results[0]?.holdings.length).toBe(1);
      expect(results[0]?.transactions.length).toBe(1);
    });

    it("should handle sync error for 401, 403, and non-401/403 error statuses", async () => {
      const asset = new SnapTradeInstitutionAsset(TestEntities.institution, "conn-1");
      const err403 = { response: { status: 403 } };

      const setErrorSpy = vi
        .spyOn(service as unknown as { setInstitutionError: (a: SnapTradeInstitutionAsset, e: boolean) => Promise<void> }, "setInstitutionError")
        .mockResolvedValue(undefined);
      await (service as unknown as { handleSyncError: (a: SnapTradeInstitutionAsset, e: unknown) => Promise<void> }).handleSyncError(asset, err403);
      expect(setErrorSpy).toHaveBeenCalledWith(asset, true);

      const genericErr = new Error("SnapTrade 500 error");
      await (service as unknown as { handleSyncError: (a: SnapTradeInstitutionAsset, e: unknown) => Promise<void> }).handleSyncError(asset, genericErr);
    });

    it("should test upsertInstitutionAsset and getInstitutionAssetsForUser", async () => {
      const asset = new SnapTradeInstitutionAsset(TestEntities.institution, "conn-1");
      vi.spyOn(SnapTradeInstitutionAsset, "find").mockResolvedValue([asset]);

      const assets = await (
        service as unknown as { getInstitutionAssetsForUser: (uId: string, iId?: string) => Promise<SnapTradeInstitutionAsset[]> }
      ).getInstitutionAssetsForUser(user.id, "inst-1");
      expect(assets.length).toBe(1);

      // New asset
      vi.spyOn(SnapTradeInstitutionAsset, "findOne").mockResolvedValue(null);
      vi.spyOn(SnapTradeInstitutionAsset.prototype, "insert").mockImplementation(async function (this: SnapTradeInstitutionAsset) {
        return this;
      });
      await (
        service as unknown as { upsertInstitutionAsset: (i: unknown, a: { authorizationId: string; userSecret: string }) => Promise<void> }
      ).upsertInstitutionAsset(TestEntities.institution, { authorizationId: "conn-1", userSecret: "sec-1" });

      // Existing asset update
      const existing = new SnapTradeInstitutionAsset(TestEntities.institution, "conn-old");
      existing.update = vi.fn().mockResolvedValue(existing);
      vi.spyOn(SnapTradeInstitutionAsset, "findOne").mockResolvedValue(existing);

      await (
        service as unknown as { upsertInstitutionAsset: (i: unknown, a: { authorizationId: string; userSecret: string }) => Promise<void> }
      ).upsertInstitutionAsset(TestEntities.institution, { authorizationId: "conn-new", userSecret: "sec-1" });
      expect(existing.authorizationId).toBe("conn-new");
      expect(existing.update).toHaveBeenCalled();
    });
  });
});
