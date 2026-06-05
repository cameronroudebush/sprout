import { setupTests } from "@backend/test/helpers";
setupTests();

import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountType } from "@backend/account/model/account.type";
import { Configuration } from "@backend/config/core";
import { HoldingHistory } from "@backend/holding/model/holding.history.model";
import { Holding } from "@backend/holding/model/holding.model";
import { Sync } from "@backend/jobs/model/sync.model";
import { ProviderBase } from "@backend/providers/base/core";
import { ProviderSyncService } from "@backend/providers/base/sync.service";
import { TestEntities } from "@backend/test/entities";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { User } from "@backend/user/model/user.model";

describe("ProviderSyncService", () => {
  let service: ProviderSyncService;
  let transactionRuleService: jest.Mocked<TransactionRuleService>;
  let mockUser: User;
  let mockProvider: jest.Mocked<ProviderBase>;
  let mockSyncInstance: Sync;

  beforeEach(() => {
    jest.clearAllMocks();

    transactionRuleService = { applyRulesToTransactions: jest.fn() } as unknown as jest.Mocked<TransactionRuleService>;

    mockUser = TestEntities.user;

    mockProvider = {
      config: { dbType: "plaid" },
      isAvailable: jest.fn().mockResolvedValue(true),
      get: jest.fn().mockResolvedValue([]),
    } as unknown as jest.Mocked<ProviderBase>;

    mockSyncInstance = TestEntities.sync;
    mockSyncInstance.insert = jest.fn().mockResolvedValue(mockSyncInstance);
    mockSyncInstance.update = jest.fn().mockResolvedValue({});
    jest.spyOn(Sync, "fromPlain").mockReturnValue(mockSyncInstance);

    Configuration.holding.cleanupRemovedHoldings = true;

    jest.spyOn(AccountHistory.prototype, "insert").mockResolvedValue({} as any);
    jest.spyOn(Holding.prototype, "insert").mockResolvedValue({} as any);
    jest.spyOn(HoldingHistory.prototype, "insert").mockResolvedValue({} as any);
    jest.spyOn(Transaction, "upsertMany").mockResolvedValue({} as any);
    jest.spyOn(Transaction, "delete").mockResolvedValue({} as any);

    service = new ProviderSyncService(transactionRuleService);
  });

  describe("syncForProvider", () => {
    it("should exit execution early if the provider infrastructure reports as unavailable for the profile", async () => {
      mockProvider.isAvailable.mockResolvedValue(false);
      const debugSpy = jest.spyOn((service as any).logger, "debug");

      await service.syncForProvider(mockUser, mockProvider);

      expect(debugSpy).toHaveBeenCalledWith(expect.stringContaining("Provider is not enabled"));
      expect(Sync.fromPlain).not.toHaveBeenCalled();
    });

    it("should process standard sync operations smoothly and commit completion metadata to the ledger", async () => {
      jest.spyOn(Account, "count").mockResolvedValue(1);

      const result = await service.syncForProvider(mockUser, mockProvider, true);

      expect(mockSyncInstance.status).toBe("complete");
      expect(mockSyncInstance.update).toHaveBeenCalled();
      expect(result).toBe(mockSyncInstance);
    });

    it("should mark the sync task failed if structural responses accumulate institution connection context errors", async () => {
      jest.spyOn(Account, "count").mockResolvedValue(1);

      const providerAccountWithError = TestEntities.account;
      providerAccountWithError.institution.hasError = true;
      providerAccountWithError.institution.name = "Chase";

      mockProvider.get.mockResolvedValue([
        {
          account: providerAccountWithError,
        },
      ]);

      const mockAccountInDb = TestEntities.account;
      mockAccountInDb.institution.update = jest.fn().mockResolvedValue({});
      mockAccountInDb.update = jest.fn().mockResolvedValue({});

      jest.spyOn(Account, "findOne").mockResolvedValue(mockAccountInDb);

      await service.syncForProvider(mockUser, mockProvider, true);

      expect(mockSyncInstance.status).toBe("failed");
      expect(mockSyncInstance.failureReason).toBe("Connection lost with Chase");
    });

    it("should catch top-level exceptions, record error tracking states, and transmit notification structures", async () => {
      jest.spyOn(Account, "count").mockRejectedValue(new Error("Database breakdown"));

      await service.syncForProvider(mockUser, mockProvider, true);

      expect(mockSyncInstance.status).toBe("failed");
    });

    it("should bypass client message pushes entirely if optional notification flags evaluate to false parameters", async () => {
      jest.spyOn(Account, "count").mockRejectedValue(new Error("Silent crash"));

      await service.syncForProvider(mockUser, mockProvider, false);
    });
  });

  describe("syncUserAccounts Evaluation Blocks", () => {
    it("should log trace notifications and exit cleanly if the provider returns empty account listings", async () => {
      jest.spyOn(Account, "count").mockResolvedValue(5);
      mockProvider.get.mockResolvedValue([]);
      const debugSpy = jest.spyOn((service as any).logger, "debug");

      await service.syncForProvider(mockUser, mockProvider, false);

      expect(debugSpy).toHaveBeenCalledWith(expect.stringContaining("No accounts available"));
    });

    it("should skip updating database storage targets if matching operational record entities are completely missing", async () => {
      jest.spyOn(Account, "count").mockResolvedValue(1);
      mockProvider.get.mockResolvedValue([{ account: TestEntities.account }]);
      jest.spyOn(Account, "findOne").mockResolvedValue(null);

      await service.syncForProvider(mockUser, mockProvider, false);

      expect(AccountHistory.prototype.insert).not.toHaveBeenCalled();
    });
  });

  describe("handleAccountsUpdate Processing Matrix", () => {
    let mockAccountInDb: Account;

    beforeEach(() => {
      mockAccountInDb = TestEntities.account;
      mockAccountInDb.type = AccountType.investment;
      mockAccountInDb.institution.update = jest.fn();
      mockAccountInDb.update = jest.fn();

      jest.spyOn(Account, "count").mockResolvedValue(1);
      jest.spyOn(Account, "findOne").mockResolvedValue(mockAccountInDb);
    });

    it("should parse financial transaction lists, handle dynamic category linkages, and issue multi-record deletions", async () => {
      mockProvider.get.mockResolvedValue([
        {
          account: TestEntities.account,
          transactions: [TestEntities.transaction, TestEntities.transaction],
          removedTransactionIds: ["tx-old-1"],
        },
      ]);
      jest.spyOn(Holding, "getForAccount").mockResolvedValue([]);

      await service.syncForProvider(mockUser, mockProvider, false);

      expect(AccountHistory.prototype.insert).toHaveBeenCalled();
      expect(mockAccountInDb.balance).toBe(1000);
      expect(mockAccountInDb.update).toHaveBeenCalled();
    });

    it("should initialize holding instances from plain contexts on matching asset storage record cache misses", async () => {
      mockProvider.get.mockResolvedValue([
        {
          account: TestEntities.account,
          holdings: [TestEntities.holding],
        },
      ]);

      jest.spyOn(Holding, "getForAccount").mockResolvedValue([]);

      await service.syncForProvider(mockUser, mockProvider, false);

      expect(Holding.prototype.insert).toHaveBeenCalledWith(false);
    });

    it("should backup previous holding data positions to ledger history models and refresh matching live instances", async () => {
      mockProvider.get.mockResolvedValue([
        {
          account: TestEntities.account,
          holdings: [TestEntities.holding],
        },
      ]);

      const mockHoldingInDb = TestEntities.holding;
      mockHoldingInDb.update = jest.fn();
      jest.spyOn(Holding, "getForAccount").mockResolvedValue([mockHoldingInDb]);

      await service.syncForProvider(mockUser, mockProvider, false);

      expect(HoldingHistory.prototype.insert).toHaveBeenCalled();
      expect(mockHoldingInDb.shares).toBe(10);
      expect(mockHoldingInDb.update).toHaveBeenCalled();
    });

    it("should erase remaining asset holdings completely if configuration clean overrides evaluate to true", async () => {
      mockProvider.get.mockResolvedValue([{ account: TestEntities.account, holdings: [] }]);

      const mockStaleHolding = TestEntities.holding;
      mockStaleHolding.remove = jest.fn();
      jest.spyOn(Holding, "getForAccount").mockResolvedValue([mockStaleHolding]);

      await service.syncForProvider(mockUser, mockProvider, false);

      expect(mockStaleHolding.remove).toHaveBeenCalled();
    });

    it("should zero out asset balances and retain database entries if clean configs evaluate to false parameters", async () => {
      Configuration.holding.cleanupRemovedHoldings = false;
      mockProvider.get.mockResolvedValue([{ account: TestEntities.account, holdings: [] }]);

      const mockStaleHolding = TestEntities.holding;
      mockStaleHolding.update = jest.fn();
      jest.spyOn(Holding, "getForAccount").mockResolvedValue([mockStaleHolding]);

      await service.syncForProvider(mockUser, mockProvider, false);

      expect(mockStaleHolding.marketValue).toBe(0);
      expect(mockStaleHolding.update).toHaveBeenCalled();
    });
  });
});
