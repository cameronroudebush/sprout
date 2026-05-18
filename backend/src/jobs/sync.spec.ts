import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountType } from "@backend/account/model/account.type";
import { Configuration } from "@backend/config/core";
import { HoldingHistory } from "@backend/holding/model/holding.history.model";
import { Holding } from "@backend/holding/model/holding.model";
import { Sync } from "@backend/jobs/model/sync.model";
import { Notification } from "@backend/notification/model/notification.model";
import { NotificationType } from "@backend/notification/model/notification.type";
import { NotificationService } from "@backend/notification/notification.service";
import { ProviderBase } from "@backend/providers/base/core";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { User } from "@backend/user/model/user.model";
import { ProviderSyncOrchestratorJob } from "./sync";

jest.mock("@backend/config/core", () => ({
  Configuration: {
    holding: { cleanupRemovedHoldings: true },
    encryptionKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
  },
}));

jest.mock("@backend/notification/model/notification.model");
jest.mock("@backend/jobs/model/sync.model");
jest.mock("@backend/user/model/user.model");
jest.mock("@backend/account/model/account.model");
jest.mock("@backend/account/model/account.history.model");
jest.mock("@backend/transaction/model/transaction.model");
jest.mock("@backend/holding/model/holding.model");
jest.mock("@backend/holding/model/holding.history.model");

jest.mock("./base", () => {
  return {
    BackgroundJob: class {
      logger = { log: jest.fn(), error: jest.fn(), debug: jest.fn(), warn: jest.fn() };
      constructor() {}
      async start() {
        return this;
      }
    },
  };
});

describe("ProviderSync", () => {
  let transactionRuleService: jest.Mocked<TransactionRuleService>;
  let notificationService: jest.Mocked<NotificationService>;
  let provider: jest.Mocked<ProviderBase>;
  let user: User;
  let mockSyncUpdate: jest.Mock;
  let mockSyncInsert: jest.Mock;

  beforeEach(() => {
    jest.clearAllMocks();

    transactionRuleService = {
      applyRulesToTransactions: jest.fn(),
    } as unknown as jest.Mocked<TransactionRuleService>;

    notificationService = {
      notifyUser: jest.fn(),
    } as unknown as jest.Mocked<NotificationService>;

    provider = {
      config: { dbType: "plaid" },
      getAppConfiguration: jest.fn().mockReturnValue({ syncFrequency: "0 0 * * *" }),
      isAvailable: jest.fn().mockResolvedValue(true),
      get: jest.fn().mockResolvedValue([]),
    } as unknown as jest.Mocked<ProviderBase>;

    user = { id: "user-1", username: "testuser" } as User;

    jest.spyOn(User, "find").mockResolvedValue([user] as any);
    jest.spyOn(Account, "getForUser").mockResolvedValue([{ id: "acc-1" }] as any);

    mockSyncUpdate = jest.fn();
    mockSyncInsert = jest.fn().mockResolvedValue({ update: mockSyncUpdate });
    jest.spyOn(Sync, "fromPlain").mockReturnValue({ insert: mockSyncInsert } as any);
    jest.spyOn(Sync, "delete").mockResolvedValue({ affected: 1 } as any);
    jest.spyOn(Sync, "findOne").mockResolvedValue({ id: "sync-1" } as any);
  });

  describe("ProviderSyncOrchestratorJob", () => {
    it("should initialize and start jobs for all given providers", async () => {
      const orchestrator = new ProviderSyncOrchestratorJob(transactionRuleService, notificationService, [provider, provider]);
      await orchestrator.onApplicationBootstrap();
      expect(orchestrator.jobs.length).toBe(2);
    });
  });

  describe("ProviderSyncJob", () => {
    let job: any;

    beforeEach(async () => {
      const orchestrator = new ProviderSyncOrchestratorJob(transactionRuleService, notificationService, [provider]);
      await orchestrator.onApplicationBootstrap();
      job = orchestrator.jobs[0];
    });

    describe("Notifications & Orchestration", () => {
      beforeEach(() => {
        job.updateProvider = jest.fn().mockResolvedValue([{ user, success: true, msg: { title: "Success", body: "Sync complete" } }]);
      });

      it("should fire notification when shouldNotify is set to default", async () => {
        jest.spyOn(Notification, "findOne").mockResolvedValue(null);
        await job.updateNow(user);
        expect(notificationService.notifyUser).toHaveBeenCalledWith(user, "Sync complete", "Success", NotificationType.success);
      });

      it("should fire notification when shouldNotify is true and no recent notification exists", async () => {
        jest.spyOn(Notification, "findOne").mockResolvedValue(null);
        await job.updateNow(user, true);
        expect(notificationService.notifyUser).toHaveBeenCalledWith(user, "Sync complete", "Success", NotificationType.success);
      });

      it("should NOT fire notification when shouldNotify is true but a recent notification exists", async () => {
        jest.spyOn(Notification, "findOne").mockResolvedValue({ id: "recent-notification" } as any);
        await job.updateNow(user, true);
        expect(notificationService.notifyUser).not.toHaveBeenCalled();
      });

      it("should NOT fire notification when shouldNotify is explicitly false", async () => {
        jest.spyOn(Notification, "findOne").mockResolvedValue(null);
        await job.updateNow(user, false);
        expect(notificationService.notifyUser).not.toHaveBeenCalled();
      });

      it("should bypass spam check and fire notification on failure results", async () => {
        job.updateProvider = jest.fn().mockResolvedValue([{ user, success: false, msg: { title: "Error", body: "Sync failed" } }]);
        jest.spyOn(Notification, "findOne").mockResolvedValue({ id: "recent-notification" } as any);
        await job.updateNow(user, true);
        expect(notificationService.notifyUser).toHaveBeenCalledWith(user, "Sync failed", "Error", NotificationType.error);
      });

      it("should return the latest sync object if a specific user was passed", async () => {
        const result = await job.updateNow(user, false);
        expect(Sync.findOne).toHaveBeenCalled();
        expect(result).toEqual({ id: "sync-1" });
      });

      it("should return null if no specific user was passed", async () => {
        const result = await job.updateNow(undefined, false);
        expect(Sync.findOne).not.toHaveBeenCalled();
        expect(result).toBeNull();
      });
    });

    describe("Provider Updates", () => {
      beforeEach(() => {
        jest.spyOn(AccountHistory, "fromPlain").mockReturnValue({ insert: jest.fn().mockResolvedValue({}) } as any);
        jest.spyOn(Transaction, "find").mockResolvedValue([]);
        jest.spyOn(Transaction, "fromPlain").mockReturnValue({ insert: jest.fn().mockResolvedValue({}) } as any);
        jest.spyOn(Holding, "getForAccount").mockResolvedValue([]);
        jest.spyOn(Holding, "fromPlain").mockReturnValue({ insert: jest.fn().mockResolvedValue({}) } as any);
        jest.spyOn(HoldingHistory, "fromPlain").mockReturnValue({ insert: jest.fn().mockResolvedValue({}) } as any);
      });

      it("should skip update if provider is not available for user", async () => {
        provider.isAvailable.mockResolvedValueOnce(false);
        const results = await job["updateProvider"](provider, user);
        expect(results).toEqual([]);
      });

      it("should complete early if user has no accounts", async () => {
        jest.spyOn(Account, "getForUser").mockResolvedValue([]);
        await job["updateProvider"](provider, user);
        expect(mockSyncUpdate).toHaveBeenCalled();
        expect(provider.get).not.toHaveBeenCalled();
      });

      it("should catch top-level errors and mark sync as failed", async () => {
        jest.spyOn(Account, "getForUser").mockRejectedValue(new Error("DB failure"));
        const results = await job["updateProvider"](provider, user);
        expect(results[0].success).toBe(false);
        expect(mockSyncUpdate).toHaveBeenCalled();
      });

      it("should successfully sync provider data, tracking institution errors", async () => {
        const mockAccount = {
          id: "acc-1",
          balance: 100,
          type: AccountType.investment,
          institution: { hasError: false, url: "test.com", update: jest.fn().mockResolvedValue({}) },
          update: jest.fn().mockResolvedValue({}),
          name: "Checking",
        };

        provider.get.mockResolvedValue([
          {
            account: { id: "acc-1", balance: 200, institution: { hasError: true, url: "new.com", name: "Bank" } } as any,
            transactions: [{ id: "tx-1", amount: 10 } as any],
            holdings: [{ symbol: "AAPL", shares: 10 } as any],
          },
        ]);

        jest.spyOn(Account, "findOne").mockResolvedValue(mockAccount as any);

        const results = await job["updateProvider"](provider, user);

        expect(mockAccount.balance).toBe(200);
        expect(mockAccount.institution.hasError).toBe(true);
        expect(transactionRuleService.applyRulesToTransactions).toHaveBeenCalled();
        expect(results[0].success).toBe(false);
      });

      it("should catch errors specific to a single account sync and continue", async () => {
        provider.get.mockResolvedValue([
          {
            account: { id: "acc-1", balance: 200, institution: { hasError: false } } as any,
          },
        ]);
        jest.spyOn(Account, "findOne").mockRejectedValue(new Error("Lookup failed"));

        await job["updateProvider"](provider, user);
        expect(job.logger.error).toHaveBeenCalledWith("Account error: Lookup failed");
      });

      it("should skip account processing if account is not found in database", async () => {
        provider.get.mockResolvedValue([{ account: { id: "acc-1" } as any }]);
        jest.spyOn(Account, "findOne").mockResolvedValue(null);
        await job["updateProvider"](provider, user);
        expect(AccountHistory.fromPlain).not.toHaveBeenCalled();
      });
    });

    describe("Transaction Data", () => {
      let mockAccount: any;

      beforeEach(() => {
        mockAccount = { id: "acc-1", name: "Checking" };
      });

      it("should insert a new transaction if it does not exist", async () => {
        const insertSpy = jest.fn().mockResolvedValue({});
        jest.spyOn(Transaction, "fromPlain").mockReturnValue({ insert: insertSpy } as any);
        jest.spyOn(Transaction, "find").mockResolvedValue([]);

        await job["updateTransactionData"](mockAccount, [{ id: "tx-1", amount: 10, description: "Test" }]);
        expect(Transaction.fromPlain).toHaveBeenCalledWith(expect.objectContaining({ id: "tx-1" }));
        expect(insertSpy).toHaveBeenCalledWith(false);
      });

      it("should fallback to account name if transaction description is empty", async () => {
        jest.spyOn(Transaction, "fromPlain").mockReturnValue({ insert: jest.fn().mockResolvedValue({}) } as any);
        jest.spyOn(Transaction, "find").mockResolvedValue([]);

        await job["updateTransactionData"](mockAccount, [{ id: "tx-1", amount: 10, description: "" }]);
        expect(Transaction.fromPlain).toHaveBeenCalledWith(expect.objectContaining({ description: "Checking" }));
      });

      it("should update an existing transaction", async () => {
        const mockTxInDb = { id: "tx-1", amount: 5, extra: {}, category: null, update: jest.fn().mockResolvedValue({}) };
        jest.spyOn(Transaction, "find").mockResolvedValue([mockTxInDb as any]);

        await job["updateTransactionData"](mockAccount, [{ id: "tx-1", amount: 10, pending: false, posted: true, extra: { note: "test" }, category: "Food" }]);
        expect(mockTxInDb.amount).toBe(10);
        expect(mockTxInDb.category).toBe("Food");
        expect(mockTxInDb.update).toHaveBeenCalled();
      });
    });

    describe("Holding Data", () => {
      let mockAccount: any;

      beforeEach(() => {
        mockAccount = { id: "acc-1" };
        jest.spyOn(Holding, "fromPlain").mockReturnValue({ insert: jest.fn().mockResolvedValue({}) } as any);
        jest.spyOn(HoldingHistory, "fromPlain").mockReturnValue({ insert: jest.fn().mockResolvedValue({}) } as any);
      });

      it("should insert a new holding if it does not exist", async () => {
        jest.spyOn(Holding, "getForAccount").mockResolvedValue([]);
        await job["updateHoldingData"](mockAccount, [{ symbol: "AAPL", shares: 10 }]);
        expect(Holding.fromPlain).toHaveBeenCalled();
      });

      it("should update an existing holding and record history", async () => {
        const mockHoldingInDb = { id: "h-1", symbol: "AAPL", shares: 5, update: jest.fn().mockResolvedValue({}) };
        jest.spyOn(Holding, "getForAccount").mockResolvedValue([mockHoldingInDb as any]);

        await job["updateHoldingData"](mockAccount, [{ symbol: "AAPL", shares: 10 }]);
        expect(HoldingHistory.fromPlain).toHaveBeenCalled();
        expect(mockHoldingInDb.shares).toBe(10);
      });

      it("should delete removed holdings if configuration allows", async () => {
        Configuration.holding.cleanupRemovedHoldings = true;
        const mockHoldingInDb = { id: "h-1", symbol: "TSLA", remove: jest.fn().mockResolvedValue({}) };
        jest.spyOn(Holding, "getForAccount").mockResolvedValue([mockHoldingInDb as any]);

        await job["updateHoldingData"](mockAccount, []);
        expect(mockHoldingInDb.remove).toHaveBeenCalled();
      });

      it("should zero out removed holdings if configuration cleanup is disabled", async () => {
        Configuration.holding.cleanupRemovedHoldings = false;
        const mockHoldingInDb = { id: "h-1", symbol: "TSLA", marketValue: 500, update: jest.fn().mockResolvedValue({}) };
        jest.spyOn(Holding, "getForAccount").mockResolvedValue([mockHoldingInDb as any]);

        await job["updateHoldingData"](mockAccount, []);
        expect(mockHoldingInDb.marketValue).toBe(0);
        expect(mockHoldingInDb.update).toHaveBeenCalled();
      });
    });

    describe("Cleanup Old Syncs", () => {
      it("should successfully clean up old records", async () => {
        jest.spyOn(Sync, "delete").mockResolvedValue({ affected: 5 } as any);
        await job["cleanupOldSyncs"](30);
        expect(Sync.delete).toHaveBeenCalled();
      });

      it("should log an error if cleanup fails", async () => {
        jest.spyOn(Sync, "delete").mockRejectedValue(new Error("DB Error"));
        await job["cleanupOldSyncs"]();
        expect(job.logger.error).toHaveBeenCalledWith(expect.stringContaining("DB Error"));
      });
    });
  });
});
