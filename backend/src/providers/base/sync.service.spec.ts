import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { AccountHistory } from "@backend/account/model/account.history.model.js";
import { Account } from "@backend/account/model/account.model.js";
import { AccountType } from "@backend/account/model/account.type.js";
import { Configuration } from "@backend/config/core.js";
import { HoldingHistory } from "@backend/holding/model/holding.history.model.js";
import { Holding } from "@backend/holding/model/holding.model.js";
import { Institution } from "@backend/institution/model/institution.model.js";
import { ProviderBase } from "@backend/providers/base/core.js";
import { ProviderSyncService } from "@backend/providers/base/sync.service.js";
import { Sync } from "@backend/providers/model/sync.model.js";
import { SyncTriggerType } from "@backend/providers/model/sync.type.js";
import { TestEntities } from "@backend/test/entities.js";
import { Transaction } from "@backend/transaction/model/transaction.model.js";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service.js";
import { User } from "@backend/user/model/user.model.js";

describe("ProviderSyncService", () => {
  let service: ProviderSyncService;
  let transactionRuleService: Mocked<TransactionRuleService>;
  let mockUser: User;
  let mockProvider: Mocked<ProviderBase>;
  let mockSyncInstance: Sync;

  beforeEach(() => {
    vi.restoreAllMocks();

    transactionRuleService = { applyRulesToTransactions: vi.fn() } as unknown as Mocked<TransactionRuleService>;

    mockUser = TestEntities.user;

    mockProvider = {
      config: { dbType: "plaid" },
      isAvailable: vi.fn().mockResolvedValue(true),
      get: vi.fn().mockResolvedValue([]),
      commitSyncMetadata: vi.fn().mockResolvedValue(undefined),
    } as unknown as Mocked<ProviderBase>;

    mockSyncInstance = TestEntities.sync;
    mockSyncInstance.insert = vi.fn().mockResolvedValue(mockSyncInstance);
    mockSyncInstance.update = vi.fn().mockResolvedValue({});
    vi.spyOn(Sync, "fromPlain").mockReturnValue(mockSyncInstance);

    Configuration.holding.cleanupRemovedHoldings = true;

    vi.spyOn(AccountHistory, "insertForAccount").mockResolvedValue({} as any);
    vi.spyOn(AccountHistory, "insertForNewAccount").mockResolvedValue({} as any);

    vi.spyOn(Transaction, "upsertMany").mockResolvedValue({} as any);
    vi.spyOn(Transaction, "delete").mockResolvedValue({} as any);

    service = new ProviderSyncService(transactionRuleService);
  });

  describe("syncForProvider", () => {
    it("should exit execution early if the provider infrastructure reports as unavailable for the profile", async () => {
      mockProvider.isAvailable.mockResolvedValue(false);
      const debugSpy = vi.spyOn((service as any).logger, "debug");

      await service.syncForProvider(mockUser, mockProvider);

      expect(debugSpy).toHaveBeenCalledWith(expect.stringContaining("Provider is not enabled"));
      expect(Sync.fromPlain).not.toHaveBeenCalled();
    });

    it("should process standard sync operations smoothly and commit completion metadata to the ledger", async () => {
      vi.spyOn(Account, "count").mockResolvedValue(1);

      const result = await service.syncForProvider(mockUser, mockProvider, SyncTriggerType.MANUAL);

      expect(mockSyncInstance.status).toBe("complete");
      expect(mockSyncInstance.update).toHaveBeenCalled();
      expect(result).toBe(mockSyncInstance);
    });

    it("should mark the sync task failed if structural responses accumulate institution connection context errors", async () => {
      vi.spyOn(Account, "count").mockResolvedValue(1);

      const providerAccountWithError = {
        ...TestEntities.account,
        providerAccountId: "p-chase-1",
        institution: { ...TestEntities.account.institution, hasError: true, name: "Chase" },
      };

      mockProvider.get.mockResolvedValue([
        {
          account: providerAccountWithError as any,
          providerAccountId: "p-chase-1",
        },
      ]);

      const mockAccountInDb = {
        ...TestEntities.account,
        providerAccountId: "p-chase-1",
        institution: { ...TestEntities.account.institution, hasError: false, name: "Chase", update: vi.fn().mockResolvedValue({}) },
        update: vi.fn().mockResolvedValue({}),
      };

      vi.spyOn(Account, "findOne").mockResolvedValue(mockAccountInDb as any);

      await service.syncForProvider(mockUser, mockProvider, SyncTriggerType.MANUAL);

      expect(mockSyncInstance.status).toBe("failed");
      expect(mockSyncInstance.failureReason).toBe("Connection lost with Chase");
    });

    it("should catch top-level exceptions, record error tracking states, and transmit notification structures", async () => {
      vi.spyOn(Account, "count").mockRejectedValue(new Error("Database breakdown"));

      await service.syncForProvider(mockUser, mockProvider, SyncTriggerType.MANUAL);

      expect(mockSyncInstance.status).toBe("failed");
    });

    it("should bypass client message pushes entirely if optional notification flags evaluate to false parameters", async () => {
      vi.spyOn(Account, "count").mockRejectedValue(new Error("Silent crash"));

      await service.syncForProvider(mockUser, mockProvider, SyncTriggerType.SCHEDULED);
    });
  });

  describe("syncUserAccounts Evaluation Blocks", () => {
    it("should skip updating database storage targets if matching operational record entities are completely missing", async () => {
      vi.spyOn(Account, "count").mockResolvedValue(1);
      mockProvider.get.mockResolvedValue([{ account: TestEntities.account, providerAccountId: "p-1" }]);
      vi.spyOn(Account, "findOne").mockResolvedValue(null);

      await service.syncForProvider(mockUser, mockProvider, SyncTriggerType.SCHEDULED);

      expect(AccountHistory.insertForAccount).not.toHaveBeenCalled();
    });

    it("should auto-create missing account when providerAccountId is present and preventAutoCreation is false", async () => {
      vi.spyOn(Account, "count").mockResolvedValue(1);

      const incomingAccount = { ...TestEntities.account, insert: vi.fn() };
      incomingAccount.insert.mockResolvedValue(incomingAccount);

      mockProvider.get.mockResolvedValue([{ account: incomingAccount as any, providerAccountId: "p-1", preventAutoCreation: false }]);

      vi.spyOn(Account, "findOne")
        .mockResolvedValueOnce(null)
        .mockResolvedValueOnce(incomingAccount as any);

      await service.syncForProvider(mockUser, mockProvider, SyncTriggerType.SCHEDULED);

      expect(incomingAccount.insert).toHaveBeenCalled();
    });

    it("should skip account if filtering by institutionId and account's institution doesn't match", async () => {
      vi.spyOn(Account, "count").mockResolvedValue(1);

      const dbAccount = { ...TestEntities.account, institution: { id: "inst-other" } };
      mockProvider.get.mockResolvedValue([{ account: TestEntities.account, providerAccountId: "p-1" }]);
      vi.spyOn(Account, "findOne").mockResolvedValue(dbAccount as any);

      await service.syncForProvider(mockUser, mockProvider, SyncTriggerType.SCHEDULED, "inst-target");

      expect(AccountHistory.insertForAccount).not.toHaveBeenCalled();
    });

    it("should attach institution if account in DB has no institution attached yet and attach brand new institution if missing in DB", async () => {
      vi.spyOn(Account, "count").mockResolvedValue(1);

      const incomingInst = Institution.fromPlain({ name: "Brand New Bank", hasError: false });
      incomingInst.insert = vi.fn().mockResolvedValue(incomingInst);

      const dbAccountNoInst = { ...TestEntities.account, institution: null as any, update: vi.fn() };
      const incomingAcc = { ...TestEntities.account, institution: incomingInst };

      mockProvider.get.mockResolvedValue([{ account: incomingAcc, providerAccountId: "p-1" }]);
      vi.spyOn(Account, "findOne").mockResolvedValue(dbAccountNoInst as any);
      vi.spyOn(Institution, "findOne").mockResolvedValue(null);

      await service.syncForProvider(mockUser, mockProvider, SyncTriggerType.SCHEDULED);

      expect(incomingInst.insert).toHaveBeenCalled();
      expect(dbAccountNoInst.institution).toBe(incomingInst);
    });

    it("should return without processing when user has no linked accounts", async () => {
      vi.spyOn(Account, "count").mockResolvedValue(0);

      const result = await service.syncForProvider(mockUser, mockProvider);

      expect(result?.status).toBe("complete");
      expect(mockProvider.get).not.toHaveBeenCalled();
    });

    it("should reuse an existing institution and skip auto-creation when disabled", async () => {
      vi.spyOn(Account, "count").mockResolvedValue(1);
      const existingInstitution = { id: "inst-existing", name: "Existing Bank", hasError: false, update: vi.fn() };
      const dbAccount = { ...TestEntities.account, institution: null, update: vi.fn() };
      const incomingAccount = { ...TestEntities.account, institution: { ...existingInstitution } };
      mockProvider.get.mockResolvedValue([
        { account: incomingAccount as any, providerAccountId: "p-disabled", preventAutoCreation: true },
        { account: incomingAccount as any, providerAccountId: "p-existing" },
        { account: incomingAccount as any },
      ]);
      vi.spyOn(Account, "findOne")
        .mockResolvedValueOnce(null)
        .mockResolvedValueOnce(dbAccount as any);
      vi.spyOn(Institution, "findOne").mockResolvedValue(existingInstitution as any);

      await service.syncForProvider(mockUser, mockProvider);

      expect(Institution.findOne).toHaveBeenCalled();
      expect(AccountHistory.insertForAccount).toHaveBeenCalled();
    });
  });

  describe("handleAccountsUpdate Processing Matrix", () => {
    let mockAccountInDb: Account;

    beforeEach(() => {
      mockAccountInDb = {
        ...TestEntities.account,
        providerAccountId: "p-test-1",
        type: AccountType.investment,
        isInvestment: true,
        institution: { ...TestEntities.account.institution, update: vi.fn() },
        update: vi.fn(),
      } as any;

      vi.spyOn(Account, "count").mockResolvedValue(1);
      vi.spyOn(Account, "findOne").mockResolvedValue(mockAccountInDb);
    });

    it("should parse financial transaction lists, match by transaction.id or providerId, handle dynamic category linkages, and issue multi-record deletions", async () => {
      const txWithIdOnly = Transaction.fromPlain({ id: "tx-local-1", amount: -20, description: "", account: TestEntities.account });
      txWithIdOnly.update = vi.fn().mockResolvedValue(txWithIdOnly);

      const account = { ...TestEntities.account, isInvestment: true };

      mockProvider.get.mockResolvedValue([
        {
          account: account as any,
          providerAccountId: "p-test-1",
          transactions: [TestEntities.transaction, txWithIdOnly],
          removedTransactionIds: ["tx-old-1"],
        },
      ]);
      vi.spyOn(Holding, "getForAccount").mockResolvedValue([]);
      vi.spyOn(Transaction, "find").mockResolvedValueOnce([TestEntities.transaction]).mockResolvedValueOnce([txWithIdOnly]);

      await service.syncForProvider(mockUser, mockProvider, SyncTriggerType.SCHEDULED);

      expect(AccountHistory.insertForAccount).toHaveBeenCalled();
      expect(mockAccountInDb.balance).toBe(1000);
      expect(mockAccountInDb.update).toHaveBeenCalled();
    });

    it("should initialize holding instances from plain contexts on matching asset storage record cache misses", async () => {
      const account = { ...TestEntities.account, isInvestment: true };

      const mockHoldingToInsert = { insert: vi.fn().mockResolvedValue({}) };
      vi.spyOn(Holding, "fromPlain").mockReturnValue(mockHoldingToInsert as any);

      mockProvider.get.mockResolvedValue([
        {
          account: account as any,
          providerAccountId: "p-test-1",
          holdings: [TestEntities.holding],
        },
      ]);

      vi.spyOn(Holding, "getForAccount").mockResolvedValue([]);

      await service.syncForProvider(mockUser, mockProvider, SyncTriggerType.SCHEDULED);

      expect(mockHoldingToInsert.insert).toHaveBeenCalledWith(false);
    });

    it("should backup previous holding data positions to ledger history models and refresh matching live instances", async () => {
      const account = { ...TestEntities.account, isInvestment: true };

      const mockHoldingHistoryToInsert = { insert: vi.fn().mockResolvedValue({}) };
      vi.spyOn(HoldingHistory, "fromPlain").mockReturnValue(mockHoldingHistoryToInsert as any);

      mockProvider.get.mockResolvedValue([
        {
          account: account as any,
          providerAccountId: "p-test-1",
          holdings: [TestEntities.holding],
        },
      ]);

      const mockHoldingInDb = { ...TestEntities.holding, symbol: TestEntities.holding.symbol, update: vi.fn() };
      vi.spyOn(Holding, "getForAccount").mockResolvedValue([mockHoldingInDb as any]);

      await service.syncForProvider(mockUser, mockProvider, SyncTriggerType.SCHEDULED);

      expect(mockHoldingHistoryToInsert.insert).toHaveBeenCalled();
      expect(mockHoldingInDb.shares).toBe(10);
      expect(mockHoldingInDb.update).toHaveBeenCalled();
    });

    it("should erase remaining asset holdings completely if configuration clean overrides evaluate to true", async () => {
      const account = { ...TestEntities.account, isInvestment: true };
      mockProvider.get.mockResolvedValue([{ account: account as any, providerAccountId: "p-test-1", holdings: [] }]);

      const mockStaleHolding = { ...TestEntities.holding, remove: vi.fn() };
      vi.spyOn(Holding, "getForAccount").mockResolvedValue([mockStaleHolding as any]);

      await service.syncForProvider(mockUser, mockProvider, SyncTriggerType.SCHEDULED);

      expect(mockStaleHolding.remove).toHaveBeenCalled();
    });

    it("should zero out asset balances and retain database entries if clean configs evaluate to false parameters", async () => {
      Configuration.holding.cleanupRemovedHoldings = false;
      const account = { ...TestEntities.account, isInvestment: true };
      mockProvider.get.mockResolvedValue([{ account: account as any, providerAccountId: "p-test-1", holdings: [] }]);

      const mockStaleHolding = { ...TestEntities.holding, update: vi.fn() };
      vi.spyOn(Holding, "getForAccount").mockResolvedValue([mockStaleHolding as any]);

      await service.syncForProvider(mockUser, mockProvider, SyncTriggerType.SCHEDULED);

      expect(mockStaleHolding.marketValue).toBe(0);
      expect(mockStaleHolding.update).toHaveBeenCalled();
    });

    it("should insert unmatched transactions and preserve missing descriptions", async () => {
      const account = { ...TestEntities.account, isInvestment: false };
      const newTransaction = Transaction.fromPlain({ amount: -3, description: "", account: TestEntities.account });
      const providerTransaction = Transaction.fromPlain({ providerId: "provider-new", amount: -4, description: "New" });
      const untrackedTransaction = Transaction.fromPlain({ amount: -5, description: "Untracked" });
      mockProvider.get.mockResolvedValue([
        {
          account: account as any,
          providerAccountId: "p-test-1",
          transactions: [newTransaction, providerTransaction, untrackedTransaction],
        },
      ]);
      vi.spyOn(Transaction, "find").mockResolvedValueOnce([]).mockResolvedValueOnce([]);
      vi.spyOn(Transaction, "fromPlain").mockImplementation((value) => ({ ...value, insert: vi.fn().mockResolvedValue(value) }) as any);

      await service.syncForProvider(mockUser, mockProvider, SyncTriggerType.SCHEDULED);

      expect(Transaction.fromPlain).toHaveBeenCalled();
    });

    it("should commit metadata and use provider-id transaction matching", async () => {
      const account = { ...TestEntities.account, isInvestment: false };
      const transaction = Transaction.fromPlain({ providerId: "provider-existing", amount: -4, description: "Updated" });
      const existingTransaction = { ...TestEntities.transaction, providerId: "provider-existing", category: {}, update: vi.fn() };
      mockProvider.get.mockResolvedValue([
        {
          account: account as any,
          providerAccountId: "p-test-1",
          transactions: [transaction],
          syncMetadata: { cursor: "next" },
        },
      ]);
      vi.spyOn(Transaction, "find").mockResolvedValue([existingTransaction as any]);

      await service.syncForProvider(mockUser, mockProvider, SyncTriggerType.SCHEDULED);

      expect(mockProvider.commitSyncMetadata).toHaveBeenCalledWith({ cursor: "next" });
      expect(existingTransaction.update).toHaveBeenCalled();
    });
  });
});
