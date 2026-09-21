import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it, vi } from "vitest";

setupTests();

import { Account } from "@backend/account/model/account.model.js";
import { AccountSubType } from "@backend/account/model/account.sub.type.js";
import { AccountType } from "@backend/account/model/account.type.js";
import { Institution } from "@backend/institution/model/institution.model.js";
import { BaseProviderConfig } from "@backend/providers/base/config.js";
import { ProviderBase } from "@backend/providers/base/core.js";
import { ProviderConfig } from "@backend/providers/base/model/provider.config.model.js";
import { ProviderRateLimit } from "@backend/providers/base/rate-limit.js";
import { SyncTriggerType } from "@backend/providers/model/sync.type.js";
import { TestEntities } from "@backend/test/entities.js";
import { InternalServerErrorException, Logger, NotImplementedException } from "@nestjs/common";

class TestProvider extends ProviderBase {
  protected readonly logger = new Logger("TestProvider");
  config = { dbType: "plaid", name: "Plaid", url: "https://plaid.com" } as ProviderConfig;
  getAppConfiguration = () => new BaseProviderConfig();
  rateLimit = () => new ProviderRateLimit("plaid" as any, 100);
  isAvailable = async () => true;
  generateLinkToken = async () => "token-123" as any;

  protected performSync = vi.fn().mockResolvedValue([]);
  protected performExchange = vi.fn().mockResolvedValue([]);
  protected mapToSproutAccount = vi.fn();
  protected getInstitutionAssetsForUser = vi.fn().mockResolvedValue([]);

  public testDetermineType(raw: string, bal: number, holdings: boolean, fallback?: AccountType) {
    return this.determineAccountType(raw, bal, holdings, fallback);
  }

  public testDetermineSubType(raw: string, fallback?: AccountSubType) {
    return this.determineAccountSubType(raw, fallback);
  }
}

describe("ProviderBase", () => {
  let provider: TestProvider;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.restoreAllMocks();
    provider = new TestProvider();
  });

  describe("get & reconcileMissingAccounts", () => {
    it("should execute performSync for each asset and reconcile missing accounts on SCHEDULED trigger", async () => {
      const asset = { id: "asset-1" };
      (provider as any).getInstitutionAssetsForUser.mockResolvedValue([asset]);
      (provider as any).performSync.mockResolvedValue([{ providerAccountId: "acc-active", account: { providerAccountId: "acc-active" } as any }]);

      const activeAcc = TestEntities.account;
      activeAcc.providerAccountId = "acc-active";
      activeAcc.isArchived = false;

      const missingAcc = {
        ...TestEntities.account,
        id: "missing-1",
        name: "Missing Acc",
        providerAccountId: "acc-missing",
        isArchived: false,
        update: vi.fn(),
      };
      const restoredAcc = {
        ...TestEntities.account,
        id: "restored-1",
        name: "Restored Acc",
        providerAccountId: "acc-active",
        isArchived: true,
        update: vi.fn(),
      };

      vi.spyOn(Account, "find").mockResolvedValue([missingAcc as any, restoredAcc as any]);

      const results = await provider.get(user, false, SyncTriggerType.SCHEDULED);

      expect(results).toHaveLength(1);
      expect(missingAcc.isArchived).toBe(true);
      expect(missingAcc.update).toHaveBeenCalled();
      expect(restoredAcc.isArchived).toBe(false);
      expect(restoredAcc.update).toHaveBeenCalled();
    });

    it("should handle sync error per asset gracefully", async () => {
      const asset = { id: "asset-1" };
      (provider as any).getInstitutionAssetsForUser.mockResolvedValue([asset]);
      (provider as any).performSync.mockRejectedValue(new Error("Sync crash"));
      vi.spyOn(Account, "find").mockResolvedValue([]);

      const handleErrSpy = vi.spyOn(provider as any, "handleSyncError").mockResolvedValue();

      const results = await provider.get(user, false, SyncTriggerType.MANUAL);
      expect(results).toHaveLength(0);
      expect(handleErrSpy).toHaveBeenCalledWith(asset, expect.any(Error));
    });
  });

  describe("exchangeAndCreateAccounts", () => {
    it("should exchange credentials and create institution and accounts with holdings and transactions", async () => {
      const rawAccount = { id: "p-acc-1", name: "Checking" };
      const exchangeInst = {
        institutionName: "New Bank",
        institutionUrl: "https://newbank.com",
        authContext: { accessToken: "at-123" },
        rawAccounts: [rawAccount],
      };

      (provider as any).performExchange.mockResolvedValue([exchangeInst]);

      vi.spyOn(Institution, "findOne").mockResolvedValue(null);

      const instMock = { id: "inst-1", hasError: false, insert: vi.fn().mockReturnThis(), update: vi.fn() };
      vi.spyOn(Institution.prototype, "insert").mockResolvedValue(instMock as any);

      const mappedAccount = { ...TestEntities.account, providerAccountId: "p-acc-1", balance: 500, insert: vi.fn().mockResolvedValue(TestEntities.account) };
      (provider as any).mapToSproutAccount.mockResolvedValue(mappedAccount);
      vi.spyOn(Account, "findOne").mockResolvedValue(null);

      const mockHolding = { insert: vi.fn().mockResolvedValue({}) };
      const mockTx = TestEntities.transaction;
      vi.spyOn(provider as any, "fetchInitialSyncData").mockResolvedValue({
        holdings: [mockHolding],
        transactions: [mockTx],
        removedTransactionIds: [],
      });

      const results = await provider.exchangeAndCreateAccounts(user, { publicToken: "pt-123" });

      expect(results).toHaveLength(1);
      expect(results[0]!.account).toBeDefined();
      expect(mockHolding.insert).toHaveBeenCalled();
    });

    it("should rollback exchange and throw InternalServerErrorException on error", async () => {
      const exchangeInst = { institutionName: "Bank", authContext: {}, rawAccounts: [] };
      (provider as any).performExchange.mockResolvedValue([exchangeInst]);
      vi.spyOn(Institution, "findOne").mockRejectedValue(new Error("DB Error"));

      const rollbackSpy = vi.spyOn(provider as any, "rollbackExchange").mockResolvedValue();

      await expect(provider.exchangeAndCreateAccounts(user, {})).rejects.toThrow(InternalServerErrorException);
      expect(rollbackSpy).toHaveBeenCalled();
    });
  });

  describe("unlinkInstitution", () => {
    it("should return true when no assets exist", async () => {
      (provider as any).getInstitutionAssetsForUser.mockResolvedValue([]);
      expect(await provider.unlinkInstitution(user, "inst-1")).toBe(true);
    });

    it("should perform unlink and return true on success, false on failure", async () => {
      const asset = { id: "asset-1" };
      (provider as any).getInstitutionAssetsForUser.mockResolvedValue([asset]);

      const unlinkSpy = vi.spyOn(provider as any, "performUnlink").mockResolvedValue();
      expect(await provider.unlinkInstitution(user, "inst-1")).toBe(true);
      expect(unlinkSpy).toHaveBeenCalledWith(user, asset);

      unlinkSpy.mockRejectedValue(new Error("Unlink failed"));
      expect(await provider.unlinkInstitution(user, "inst-1")).toBe(false);
    });
  });

  describe("getUnlinkedAccounts", () => {
    it("should throw NotImplementedException by default", async () => {
      await expect(provider.getUnlinkedAccounts(user)).rejects.toThrow(NotImplementedException);
    });
  });

  describe("determineAccountType & determineAccountSubType", () => {
    it("should determine account type correctly", () => {
      expect(provider.testDetermineType("credit card", 0, false)).toBe(AccountType.credit);
      expect(provider.testDetermineType("crypto wallet", 100, false)).toBe(AccountType.crypto);
      expect(provider.testDetermineType("brokerage", 100, true)).toBe(AccountType.investment);
      expect(provider.testDetermineType("checking", 500, false)).toBe(AccountType.depository);
      expect(provider.testDetermineType("personal loan", -500, false)).toBe(AccountType.loan);
      expect(provider.testDetermineType(null, 0, false, AccountType.other)).toBe(AccountType.other);
    });

    it("should determine account subType correctly", () => {
      expect(provider.testDetermineSubType("checking")).toBe(AccountSubType.checking);
      expect(provider.testDetermineSubType("savings")).toBe(AccountSubType.savings);
      expect(provider.testDetermineSubType("hysa")).toBe(AccountSubType.hysa);
      expect(provider.testDetermineSubType("401k")).toBe(AccountSubType["401k"]);
      expect(provider.testDetermineSubType("roth ira")).toBe(AccountSubType.ira);
      expect(provider.testDetermineSubType("hsa")).toBe(AccountSubType.hsa);
      expect(provider.testDetermineSubType("student loan")).toBe(AccountSubType.student);
      expect(provider.testDetermineSubType("mortgage")).toBe(AccountSubType.mortgage);
      expect(provider.testDetermineSubType("auto loan")).toBe(AccountSubType.auto);
      expect(provider.testDetermineSubType("crypto wallet")).toBe(AccountSubType.wallet);
      expect(provider.testDetermineSubType("personal loan")).toBe(AccountSubType.personal);
      expect(provider.testDetermineSubType("brokerage")).toBe(AccountSubType.brokerage);
      expect(provider.testDetermineSubType(null, AccountSubType.other)).toBe(AccountSubType.other);
    });
  });

  describe("default helper methods", () => {
    it("should execute default hooks without throwing", async () => {
      await (provider as any).setInstitutionError({ institution: { hasError: false, update: vi.fn() } }, true);
      expect((provider as any).extractProviderAccountId({ id: "acc-1" })).toBe("acc-1");
      expect((provider as any).extractAccountName({ accountName: "My Acc" })).toBe("My Acc");
      expect(await (provider as any).fetchInitialSyncData({}, {} as any, {}, user)).toEqual({ transactions: [], removedTransactionIds: [], holdings: [] });
      await provider.commitSyncMetadata({});
    });
  });
});
