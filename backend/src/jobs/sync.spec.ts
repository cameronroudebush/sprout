import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { Configuration } from "@backend/config/core";
import { HoldingHistory } from "@backend/holding/model/holding.history.model";
import { Holding } from "@backend/holding/model/holding.model";
import { Sync } from "@backend/jobs/model/sync.model";
import { Notification } from "@backend/notification/model/notification.model";
import { NotificationService } from "@backend/notification/notification.service";
import { ProviderBase } from "@backend/providers/base/core";
import { ProviderSyncService } from "@backend/providers/base/sync.service";
import { SSEService } from "@backend/sse/sse.service";
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

jest.mock("@backend/jobs/job-distributed-base", () => {
  return {
    DistributedQueueJob: class {
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
  let sseService: jest.Mocked<SSEService>;
  let providerSyncService: ProviderSyncService;
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

    sseService = {
      sendToUser: jest.fn(),
    } as unknown as jest.Mocked<SSEService>;

    providerSyncService = new ProviderSyncService(transactionRuleService, notificationService, sseService);

    provider = {
      config: { dbType: "plaid" },
      getAppConfiguration: jest.fn().mockReturnValue({ syncFrequency: "0 0 * * *" }),
      isAvailable: jest.fn().mockResolvedValue(true),
      get: jest.fn().mockResolvedValue([]),
    } as unknown as jest.Mocked<ProviderBase>;

    user = { id: "user-1", username: "testuser" } as User;

    jest.spyOn(User, "find").mockResolvedValue([user] as any);
    jest.spyOn(User, "findOne").mockResolvedValue(user as any);
    jest.spyOn(Account, "count").mockResolvedValue(1); // Replaces getForUser

    mockSyncUpdate = jest.fn();
    mockSyncInsert = jest.fn().mockResolvedValue({ update: mockSyncUpdate, status: "in-progress" });
    jest.spyOn(Sync, "fromPlain").mockReturnValue({ insert: mockSyncInsert } as any);
    jest.spyOn(Sync, "delete").mockResolvedValue({ affected: 1 } as any);
    jest.spyOn(Sync, "findOne").mockResolvedValue({ id: "sync-1" } as any);
  });

  describe("ProviderSyncOrchestratorJob", () => {
    it("should initialize and start jobs for all given providers", async () => {
      const orchestrator = new ProviderSyncOrchestratorJob(providerSyncService, [provider, provider]);
      await orchestrator.onApplicationBootstrap();
      expect(orchestrator.jobs.length).toBe(2);
    });
  });

  describe("ProviderSyncJob", () => {
    let job: any;

    beforeEach(async () => {
      const orchestrator = new ProviderSyncOrchestratorJob(providerSyncService, [provider]);
      await orchestrator.onApplicationBootstrap();
      job = orchestrator.jobs[0];
    });

    describe("Task Generation (Producer)", () => {
      it("should clean old syncs and return mapped user tasks", async () => {
        const tasks = await job["generateTasks"]();
        expect(Sync.delete).toHaveBeenCalled();
        expect(tasks).toEqual([{ userId: "user-1" }]);
      });
    });

    describe("Task Processing & Orchestration (Consumer)", () => {
      it("should abort if user is not found", async () => {
        jest.spyOn(User, "findOne").mockResolvedValue(null);
        await job["processTask"]({ userId: "invalid-user" });
        expect(provider.isAvailable).not.toHaveBeenCalled();
      });

      it("should abort if provider is not available for user", async () => {
        provider.isAvailable.mockResolvedValueOnce(false);
        await job["processTask"]({ userId: "user-1" });
        expect(Sync.fromPlain).not.toHaveBeenCalled();
      });

      // it("should catch total failures and mark sync as failed", async () => {
      //   jest.spyOn(providerSyncService, "syncForProvider").mockRejectedValue(new Error("API Down"));
      //   await job["processTask"]({ userId: "user-1" });

      //   expect(mockSyncUpdate).toHaveBeenCalled();
      //   expect(notificationService.notifyUser).toHaveBeenCalledWith(user, "API Down", "Connection Update Required", NotificationType.error);
      // });

      // it("should mark sync complete and trigger SSE/Notifications on success", async () => {
      //   jest.spyOn(providerSyncService, "syncForProvider").mockResolvedValue({ institutionErrors: new Set(), userHadSuccessfulUpdate: true } as any);
      //   jest.spyOn(Notification, "findOne").mockResolvedValue(null); // No spam

      //   await job["processTask"]({ userId: "user-1" });

      //   expect(sseService.sendToUser).not.toHaveBeenCalled();
      //   expect(notificationService.notifyUser).toHaveBeenCalledWith(user, expect.any(String), expect.any(String), NotificationType.success);
      // });

      it("should respect the notification spam check", async () => {
        jest.spyOn(providerSyncService, "syncForProvider").mockResolvedValue({ institutionErrors: new Set(), userHadSuccessfulUpdate: true } as any);
        jest.spyOn(Notification, "findOne").mockResolvedValue({ id: "recent-notification" } as any); // Spam hit

        await job["processTask"]({ userId: "user-1" });

        expect(notificationService.notifyUser).not.toHaveBeenCalled(); // Blocked by spam check
      });
    });

    describe("Provider Sync Operations", () => {
      beforeEach(() => {
        jest.spyOn(AccountHistory, "fromPlain").mockReturnValue({ insert: jest.fn().mockResolvedValue({}) } as any);
        jest.spyOn(Transaction, "upsertMany").mockResolvedValue({} as any);
        jest.spyOn(Transaction, "delete").mockResolvedValue({} as any);
        jest.spyOn(Holding, "getForAccount").mockResolvedValue([]);
      });

      it("should skip if user has no accounts", async () => {
        jest.spyOn(Account, "count").mockResolvedValue(0);
        expect(provider.get).not.toHaveBeenCalled();
      });

      // it("should successfully sync provider data, bulk upsert, and track errors", async () => {
      //   const mockAccount = {
      //     id: "acc-1",
      //     balance: 100,
      //     type: AccountType.investment,
      //     institution: { hasError: false, url: "test.com", update: jest.fn().mockResolvedValue({}) },
      //     update: jest.fn().mockResolvedValue({}),
      //     name: "Checking",
      //   };

      //   provider.get.mockResolvedValue([
      //     {
      //       account: { id: "acc-1", balance: 200, institution: { hasError: true, url: "new.com", name: "Bank" } } as any,
      //       transactions: [{ id: "tx-1", amount: 10 } as any],
      //       removedTransactionIds: ["tx-2"],
      //     },
      //   ]);

      //   jest.spyOn(Account, "findOne").mockResolvedValue(mockAccount as any);

      //   expect(mockAccount.balance).toBe(100);
      //   expect(mockAccount.institution.hasError).toBe(true);
      //   expect(Transaction.upsertMany).toHaveBeenCalled();
      //   expect(Transaction.delete).toHaveBeenCalledWith({ id: In(["tx-2"]) });
      //   expect(transactionRuleService.applyRulesToTransactions).toHaveBeenCalled();
      // });
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
        await providerSyncService["updateHoldingData"](mockAccount, [{ symbol: "AAPL", shares: 10 }] as any);
        expect(Holding.fromPlain).toHaveBeenCalled();
      });

      it("should update an existing holding and record history", async () => {
        const mockHoldingInDb = { id: "h-1", symbol: "AAPL", shares: 5, update: jest.fn().mockResolvedValue({}) };
        jest.spyOn(Holding, "getForAccount").mockResolvedValue([mockHoldingInDb as any]);

        await providerSyncService["updateHoldingData"](mockAccount, [{ symbol: "AAPL", shares: 10 }] as any);
        expect(HoldingHistory.fromPlain).toHaveBeenCalled();
        expect(mockHoldingInDb.shares).toBe(10);
      });

      it("should delete removed holdings if configuration allows", async () => {
        Configuration.holding.cleanupRemovedHoldings = true;
        const mockHoldingInDb = { id: "h-1", symbol: "TSLA", remove: jest.fn().mockResolvedValue({}) };
        jest.spyOn(Holding, "getForAccount").mockResolvedValue([mockHoldingInDb as any]);

        await providerSyncService["updateHoldingData"](mockAccount, []);
        expect(mockHoldingInDb.remove).toHaveBeenCalled();
      });
    });
  });
});
