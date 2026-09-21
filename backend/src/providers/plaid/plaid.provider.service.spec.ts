import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { AccountHistory } from "@backend/account/model/account.history.model.js";
import { Account } from "@backend/account/model/account.model.js";
import { AccountType } from "@backend/account/model/account.type.js";
import { Configuration } from "@backend/config/core.js";
import { ProviderRateLimit } from "@backend/providers/base/rate-limit.js";
import { PlaidLinkDTO } from "@backend/providers/plaid/model/api/link.dto.js";
import { PlaidInstitutionAsset } from "@backend/providers/plaid/model/plaid.institution.asset.js";
import { PlaidAuthContext, PlaidProviderService, PlaidSyncMetadata } from "@backend/providers/plaid/plaid.provider.service.js";
import { TestEntities } from "@backend/test/entities.js";
import { Transaction } from "@backend/transaction/model/transaction.model.js";
import { User } from "@backend/user/model/user.model.js";
import { InternalServerErrorException } from "@nestjs/common";
import { AccountType as PlaidAccountType, AccountBase as PlaidAccount } from "plaid";

describe("PlaidProviderService", () => {
  let service: PlaidProviderService;
  let user: User;

  beforeEach(() => {
    vi.restoreAllMocks();
    user = TestEntities.user;

    Configuration.providers.plaid.clientId = "test-client-id";
    Configuration.providers.plaid.secret = "test-secret";
    Configuration.providers.plaid.environment = "https://sandbox.plaid.com";

    vi.spyOn(ProviderRateLimit.prototype, "incrementOrError").mockResolvedValue(undefined);

    service = new PlaidProviderService();
    (service as unknown as { plaidClient: Record<string, unknown> }).plaidClient = {
      linkTokenCreate: vi.fn(),
      itemPublicTokenExchange: vi.fn(),
      institutionsGetById: vi.fn(),
      accountsGet: vi.fn(),
      itemRemove: vi.fn(),
      investmentsHoldingsGet: vi.fn(),
      transactionsSync: vi.fn(),
      investmentsTransactionsGet: vi.fn(),
      itemWebhookUpdate: vi.fn(),
    };
  });

  describe("isAvailable & checkPlaidClient", () => {
    it("should return availability status based on config", async () => {
      const avail = await service.isAvailable(user);
      expect(avail).toBe(true);
    });

    it("should throw InternalServerErrorException if plaidClient is null", async () => {
      (service as unknown as { plaidClient: null }).plaidClient = null;
      expect(() => (service as unknown as { checkPlaidClient: () => void }).checkPlaidClient()).toThrow(InternalServerErrorException);
      await expect(service.updateAllItemWebhooks("https://url.com")).rejects.toThrow(InternalServerErrorException);
    });
  });

  describe("generateLinkToken", () => {
    it("should create link token in standard mode", async () => {
      service.plaidClient.linkTokenCreate = vi.fn().mockResolvedValue({ data: { link_token: "link-123" } });

      const dto = await service.generateLinkToken(user, { publicUrl: "https://sprout.local" });
      expect(dto.linkToken).toBe("link-123");
    });

    it("should attempt update mode link token when institutionId provided", async () => {
      const asset = new PlaidInstitutionAsset(TestEntities.institution, "access-token-123", "item-123");
      vi.spyOn(PlaidInstitutionAsset, "findOne").mockResolvedValue(asset);

      service.plaidClient.linkTokenCreate = vi.fn().mockResolvedValue({ data: { link_token: "link-update-123" } });

      const dto = await service.generateLinkToken(user, { publicUrl: "https://sprout.local", institutionId: "inst-1" });
      expect(dto.linkToken).toBe("link-update-123");
    });

    it("should fallback to standard mode if update mode link token fails", async () => {
      const asset = new PlaidInstitutionAsset(TestEntities.institution, "access-token-123", "item-123");
      vi.spyOn(PlaidInstitutionAsset, "findOne").mockResolvedValue(asset);

      service.plaidClient.linkTokenCreate = vi
        .fn()
        .mockRejectedValueOnce(new Error("Update mode error"))
        .mockResolvedValueOnce({ data: { link_token: "link-standard-123" } });

      const dto = await service.generateLinkToken(user, { publicUrl: "https://sprout.local", institutionId: "inst-1" });
      expect(dto.linkToken).toBe("link-standard-123");
    });
  });

  describe("performExchange and rollbackExchange", () => {
    it("should exchange public token for access token and fetch accounts", async () => {
      service.plaidClient.itemPublicTokenExchange = vi.fn().mockResolvedValue({
        data: { access_token: "access-123", item_id: "item-123" },
      });
      service.plaidClient.institutionsGetById = vi.fn().mockResolvedValue({
        data: { institution: { url: "https://bank.com" } },
      });
      service.plaidClient.accountsGet = vi.fn().mockResolvedValue({
        data: { accounts: [{ account_id: "acc-1", name: "Checking" }] },
      });

      const payload = {
        publicToken: "public-123",
        metadata: { institution: { institution_id: "ins_1", name: "Bank" } },
      } as unknown as PlaidLinkDTO;

      const results = await (
        service as unknown as { performExchange: (u: User, p: PlaidLinkDTO) => Promise<Array<{ institutionUrl: string }>> }
      ).performExchange(user, payload);

      expect(results.length).toBe(1);
      expect(results[0]?.institutionUrl).toBe("https://bank.com");
    });

    it("should handle error in institutionsGetById gracefully", async () => {
      service.plaidClient.itemPublicTokenExchange = vi.fn().mockResolvedValue({
        data: { access_token: "access-123", item_id: "item-123" },
      });
      service.plaidClient.institutionsGetById = vi.fn().mockRejectedValue(new Error("Metadata error"));
      service.plaidClient.accountsGet = vi.fn().mockResolvedValue({
        data: { accounts: [] },
      });

      const payload = {
        publicToken: "public-123",
        metadata: { institution: { institution_id: "ins_1", name: "Bank" } },
      } as unknown as PlaidLinkDTO;

      const results = await (
        service as unknown as { performExchange: (u: User, p: PlaidLinkDTO) => Promise<Array<{ institutionUrl: string }>> }
      ).performExchange(user, payload);

      expect(results.length).toBe(1);
      expect(results[0]?.institutionUrl).toBe(service.config.url);
    });

    it("should rollback exchange by removing item", async () => {
      service.plaidClient.itemRemove = vi.fn().mockResolvedValue({});
      await (service as unknown as { rollbackExchange: (u: User, p: unknown, a: PlaidAuthContext) => Promise<void> }).rollbackExchange(
        user,
        {},
        { accessToken: "access-123", itemId: "item-123" },
      );
      expect(service.plaidClient.itemRemove).toHaveBeenCalledWith({ access_token: "access-123" });
    });
  });

  describe("performSync, commitSyncMetadata, and helper hooks", () => {
    it("should perform sync with accounts, transactions, holdings, and removed transactions", async () => {
      const asset = new PlaidInstitutionAsset(TestEntities.institution, "access-123", "item-123");
      asset.syncCursor = "cursor-0";

      const rawPlaidAccount = {
        account_id: "acc-1",
        name: "Investment Acc",
        type: PlaidAccountType.Investment,
        subtype: "brokerage",
        balances: { current: 1000, iso_currency_code: "USD" },
      };

      service.plaidClient.accountsGet = vi.fn().mockResolvedValue({
        data: { accounts: [rawPlaidAccount] },
      });

      service.plaidClient.investmentsHoldingsGet = vi.fn().mockResolvedValue({
        data: {
          holdings: [{ account_id: "acc-1", security_id: "sec-1", cost_basis: 100, institution_value: 120, institution_price: 12, quantity: 10 }],
          securities: [{ security_id: "sec-1", name: "Apple", ticker_symbol: "AAPL" }],
        },
      });

      service.plaidClient.investmentsTransactionsGet = vi.fn().mockResolvedValue({
        data: {
          investment_transactions: [{ investment_transaction_id: "inv-tx-1", account_id: "acc-1", amount: 50, date: "2026-06-15", name: "Buy AAPL" }],
        },
      });

      service.plaidClient.transactionsSync = vi.fn().mockResolvedValue({
        data: {
          added: [{ transaction_id: "tx-1", pending_transaction_id: "pending-123", account_id: "acc-1", amount: 20, date: "2026-06-15", name: "Store" }],
          modified: [],
          removed: [{ transaction_id: "tx-rem-1", account_id: "acc-1" }],
          next_cursor: "cursor-1",
          has_more: false,
        },
      });

      const pendingTxInDb = TestEntities.transaction;
      pendingTxInDb.remove = vi.fn().mockResolvedValue(pendingTxInDb);

      vi.spyOn(Account, "findOne").mockResolvedValue(TestEntities.account);
      vi.spyOn(Transaction, "findOne").mockResolvedValue(pendingTxInDb);
      vi.spyOn(Transaction, "find").mockResolvedValue([Transaction.fromPlain({ id: "tx-db-rem-1" })]);
      vi.spyOn(AccountHistory, "insertForAccount").mockResolvedValue({} as unknown as AccountHistory);

      const results = await (
        service as unknown as {
          performSync: (
            u: User,
            a: PlaidInstitutionAsset,
            ao: boolean,
          ) => Promise<Array<{ transactions: unknown[]; removedTransactionIds: string[]; holdings: unknown[] }>>;
        }
      ).performSync(user, asset, false);
      expect(results.length).toBe(1);
      expect(pendingTxInDb.remove).toHaveBeenCalled();
      expect(results[0]?.removedTransactionIds).toEqual(["tx-db-rem-1"]);
      expect(results[0]?.holdings?.length).toBe(1);
    });

    it("should handle error in fetchInvestmentTransactions and investmentsHoldingsGet gracefully", async () => {
      const asset = new PlaidInstitutionAsset(TestEntities.institution, "access-123", "item-123");
      const rawPlaidAccount = {
        account_id: "acc-1",
        name: "Investment Acc",
        type: PlaidAccountType.Investment,
        balances: {},
      };

      service.plaidClient.accountsGet = vi.fn().mockResolvedValue({ data: { accounts: [rawPlaidAccount] } });
      service.plaidClient.investmentsHoldingsGet = vi.fn().mockRejectedValue({ response: { data: { error_message: "Holdings error" } } });
      service.plaidClient.investmentsTransactionsGet = vi.fn().mockRejectedValue({ response: { data: { error_message: "Inv tx error" } } });
      service.plaidClient.transactionsSync = vi.fn().mockResolvedValue({ data: { added: [], modified: [], removed: [], next_cursor: "c1", has_more: false } });

      vi.spyOn(Account, "findOne").mockResolvedValue(TestEntities.account);

      const results = await (service as unknown as { performSync: (u: User, a: PlaidInstitutionAsset, ao: boolean) => Promise<unknown[]> }).performSync(
        user,
        asset,
        false,
      );
      expect(results.length).toBe(1);
    });

    it("should commitSyncMetadata and update asset cursor", async () => {
      const asset = new PlaidInstitutionAsset(TestEntities.institution, "access-123", "item-123");
      vi.spyOn(PlaidInstitutionAsset, "findOne").mockResolvedValue(asset);
      vi.spyOn(asset, "update").mockResolvedValue(asset);

      const metadata: PlaidSyncMetadata = { institutionId: "inst-1", nextCursor: "new-cursor" };
      await service.commitSyncMetadata(metadata);
      expect(asset.syncCursor).toBe("new-cursor");
      expect(asset.update).toHaveBeenCalled();
    });

    it("should handle sync error and set institution error for ITEM_LOGIN_REQUIRED and generic error", async () => {
      const asset = new PlaidInstitutionAsset(TestEntities.institution, "access-123", "item-123");
      const error = {
        response: {
          data: {
            error_type: "ITEM_ERROR",
            error_code: "ITEM_LOGIN_REQUIRED",
          },
        },
      };

      const setErrorSpy = vi
        .spyOn(service as unknown as { setInstitutionError: (a: PlaidInstitutionAsset, e: boolean) => Promise<void> }, "setInstitutionError")
        .mockResolvedValue(undefined);
      await (service as unknown as { handleSyncError: (a: PlaidInstitutionAsset, e: unknown) => Promise<void> }).handleSyncError(asset, error);
      expect(setErrorSpy).toHaveBeenCalledWith(asset, true);

      const genericError = new Error("Generic sync fail");
      await (service as unknown as { handleSyncError: (a: PlaidInstitutionAsset, e: unknown) => Promise<void> }).handleSyncError(asset, genericError);
    });

    it("should updateAllItemWebhooks for registered assets and handle error per item", async () => {
      const asset1 = new PlaidInstitutionAsset(TestEntities.institution, "access-123", "item-123");
      const asset2 = new PlaidInstitutionAsset(TestEntities.institution, "access-456", "item-456");
      vi.spyOn(PlaidInstitutionAsset, "find").mockResolvedValue([asset1, asset2]);

      service.plaidClient.itemWebhookUpdate = vi.fn().mockResolvedValueOnce({}).mockRejectedValueOnce(new Error("Webhook update error"));

      const res = await service.updateAllItemWebhooks("https://new.sprout.local");
      expect(res.successCount).toBe(1);
      expect(res.failureCount).toBe(1);
    });

    it("should test mapType, performUnlink, getInstitutionAssetsForUser, and upsertInstitutionAsset", async () => {
      type ServicePrivate = {
        mapType: (t: PlaidAccountType) => AccountType;
        performUnlink: (u: User, a: PlaidInstitutionAsset) => Promise<void>;
        getInstitutionAssetsForUser: (uId: string, iId?: string) => Promise<PlaidInstitutionAsset[]>;
        upsertInstitutionAsset: (i: unknown, a: PlaidAuthContext) => Promise<void>;
        extractProviderAccountId: (r: PlaidAccount) => string;
        extractAccountName: (r: PlaidAccount) => string;
      };
      const priv = service as unknown as ServicePrivate;

      expect(priv.mapType(PlaidAccountType.Credit)).toBe(AccountType.credit);
      expect(priv.mapType(PlaidAccountType.Depository)).toBe(AccountType.depository);
      expect(priv.mapType(PlaidAccountType.Brokerage)).toBe(AccountType.investment);
      expect(priv.mapType(PlaidAccountType.Investment)).toBe(AccountType.investment);
      expect(priv.mapType(PlaidAccountType.Loan)).toBe(AccountType.loan);

      expect(priv.extractProviderAccountId({ account_id: "acc-id-1" } as PlaidAccount)).toBe("acc-id-1");
      expect(priv.extractAccountName({ name: "Account Name 1" } as PlaidAccount)).toBe("Account Name 1");

      const asset = new PlaidInstitutionAsset(TestEntities.institution, "access-123", "item-123");
      service.plaidClient.itemRemove = vi.fn().mockResolvedValue({});
      await priv.performUnlink(user, asset);
      expect(service.plaidClient.itemRemove).toHaveBeenCalledWith({ access_token: "access-123" });

      vi.spyOn(PlaidInstitutionAsset, "find").mockResolvedValue([asset]);
      const assets = await priv.getInstitutionAssetsForUser(user.id, "inst-1");
      expect(assets.length).toBe(1);

      // New asset
      vi.spyOn(PlaidInstitutionAsset, "findOne").mockResolvedValue(null);
      vi.spyOn(PlaidInstitutionAsset.prototype, "insert").mockImplementation(async function (this: PlaidInstitutionAsset) {
        return this;
      });
      await priv.upsertInstitutionAsset(TestEntities.institution, { accessToken: "a-1", itemId: "i-1" });

      // Existing asset with new itemId
      const existingAsset = new PlaidInstitutionAsset(TestEntities.institution, "a-old", "i-old");
      existingAsset.update = vi.fn().mockResolvedValue(existingAsset);
      vi.spyOn(PlaidInstitutionAsset, "findOne").mockResolvedValue(existingAsset);
      await priv.upsertInstitutionAsset(TestEntities.institution, { accessToken: "a-new", itemId: "i-new" });
      expect(existingAsset.itemId).toBe("i-new");
      expect(existingAsset.update).toHaveBeenCalled();
    });
  });
});
