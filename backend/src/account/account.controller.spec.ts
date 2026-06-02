import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountSubType } from "@backend/account/model/account.sub.type";
import { AccountType } from "@backend/account/model/account.type";
import { DatabaseService } from "@backend/database/database.service";
import { Sync } from "@backend/jobs/model/sync.model";
import { ProviderSyncOrchestratorJob } from "@backend/jobs/sync";
import { PlaidProviderService } from "@backend/providers/plaid/plaid.provider.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { User } from "@backend/user/model/user.model";
import { BadRequestException, InternalServerErrorException, NotFoundException } from "@nestjs/common";
import { Test, TestingModule } from "@nestjs/testing";
import { SSEService } from "../sse/sse.service";
import { AccountController } from "./account.controller";

describe("AccountController", () => {
  let controller: AccountController;
  let sseService: SSEService;

  const mockUser = { id: "user-123" } as User;

  const mockAccount = {
    id: "acc-1",
    name: "Savings Account",
    user: mockUser,
    type: AccountType.depository,
    subType: AccountSubType.savings,
    interestRate: 0.05,
    update: jest.fn().mockResolvedValue({ id: "acc-1", name: "Updated Name" }),
  } as unknown as Account;

  const mockSourceAccount = {
    id: "acc-2",
    name: "Old Savings",
    user: mockUser,
    type: AccountType.depository,
    subType: AccountSubType.checking,
  } as unknown as Account;

  const mockTransactionManager = {
    save: jest.fn(),
    createQueryBuilder: jest.fn(() => ({
      update: jest.fn().mockReturnThis(),
      set: jest.fn().mockReturnThis(),
      where: jest.fn().mockReturnThis(),
      execute: jest.fn(),
    })),
    remove: jest.fn(),
  };

  const mockProviderSyncJob = {
    jobs: [],
    syncUserAllProviders: jest.fn(),
  };

  beforeEach(async () => {
    mockProviderSyncJob.syncUserAllProviders.mockResolvedValue([Sync.fromPlain({ id: "mock-sync-id", status: "complete" })]);
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AccountController],
      providers: [
        {
          provide: SSEService,
          useValue: { sendToUser: jest.fn() },
        },
        {
          provide: DatabaseService,
          useValue: {
            source: {
              transaction: jest.fn(async (cb) => cb(mockTransactionManager)),
            },
          },
        },
        {
          provide: ProviderSyncOrchestratorJob,
          useValue: mockProviderSyncJob,
        },
        {
          provide: PlaidProviderService,
          useValue: { unlinkInstitution: jest.fn() },
        },
      ],
    }).compile();

    controller = module.get<AccountController>(AccountController);
    sseService = module.get<SSEService>(SSEService);

    // Mocks for static AR methods
    Account.findOne = jest.fn();
    Account.find = jest.fn();
    Account.deleteById = jest.fn();
    Sync.findOne = jest.fn();
    AccountHistory.insertForNewAccount = jest.fn();

    // Reset the mutable mockAccount so tests don't leak state changes
    mockAccount.name = "Savings Account";
    mockAccount.type = AccountType.depository;
    mockAccount.subType = AccountSubType.savings;
    mockAccount.interestRate = 0.05;

    jest.clearAllMocks();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe("getById", () => {
    it("should return an account if found", async () => {
      (Account.findOne as jest.Mock).mockResolvedValue(mockAccount);

      const result = await controller.getById("acc-1", mockUser);
      expect(result).toEqual(mockAccount);
      expect(Account.findOne).toHaveBeenCalledWith({
        where: { id: "acc-1", user: { id: mockUser.id } },
      });
    });

    it("should throw NotFoundException if account not found", async () => {
      (Account.findOne as jest.Mock).mockResolvedValue(null);

      await expect(controller.getById("invalid", mockUser)).rejects.toThrow(NotFoundException);
    });
  });

  describe("delete", () => {
    it("should delete and notify via SSE", async () => {
      (Account.findOne as jest.Mock).mockResolvedValue(mockAccount);
      (Account.deleteById as jest.Mock).mockResolvedValue({ affected: 1 });

      const result = await controller.delete("acc-1", mockUser);

      expect(result).toContain("deleted successfully");
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
      expect(Account.deleteById).toHaveBeenCalledWith("acc-1");
    });

    it("should throw NotFoundException if account to delete not found", async () => {
      (Account.findOne as jest.Mock).mockResolvedValue(null);

      await expect(controller.delete("invalid", mockUser)).rejects.toThrow(NotFoundException);
    });

    it("should throw InternalServerErrorException if delete operation affects 0 rows", async () => {
      (Account.findOne as jest.Mock).mockResolvedValue(mockAccount);
      (Account.deleteById as jest.Mock).mockResolvedValue({ affected: 0 });

      await expect(controller.delete("acc-1", mockUser)).rejects.toThrow(InternalServerErrorException);
    });
  });

  describe("edit", () => {
    it("should update all allowed account fields and trigger SSE", async () => {
      (Account.findOne as jest.Mock).mockResolvedValue(mockAccount);
      const updateDto = {
        name: "New Valid Name",
        type: AccountType.credit,
        subType: AccountSubType.travel,
        interestRate: 15.5,
      } as any;

      await controller.edit("acc-1", mockUser, updateDto);

      expect(mockAccount.update).toHaveBeenCalled();
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
      expect(mockAccount.name).toBe("New Valid Name");
      expect(mockAccount.type).toBe(AccountType.credit);
      expect(mockAccount.subType).toBe(AccountSubType.travel);
      expect(mockAccount.interestRate).toBe(15.5);
    });

    it("should partially update fields if some are not provided", async () => {
      (Account.findOne as jest.Mock).mockResolvedValue(mockAccount);
      const originalName = mockAccount.name;
      const originalType = mockAccount.type;
      const updateDto = { subType: AccountSubType.checking } as any;

      await controller.edit("acc-1", mockUser, updateDto);

      expect(mockAccount.update).toHaveBeenCalled();
      expect(mockAccount.name).toBe(originalName);
      expect(mockAccount.type).toBe(originalType);
      expect(mockAccount.subType).toBe(AccountSubType.checking);
    });

    it("should throw NotFoundException if account to edit is not found", async () => {
      (Account.findOne as jest.Mock).mockResolvedValue(null);
      const updateDto = { name: "New Name" };

      await expect(controller.edit("invalid", mockUser, updateDto)).rejects.toThrow(NotFoundException);
    });

    it("should throw BadRequestException if name is too short", async () => {
      (Account.findOne as jest.Mock).mockResolvedValue(mockAccount);
      const updateDto = { name: "Shot" };

      await expect(controller.edit("acc-1", mockUser, updateDto)).rejects.toThrow(BadRequestException);
    });
  });

  describe("getAccounts", () => {
    it("should return an array of accounts for the user", async () => {
      (Account.find as jest.Mock).mockResolvedValue([mockAccount]);

      const result = await controller.getAccounts(mockUser);
      expect(result).toEqual([mockAccount]);
      expect(Account.find).toHaveBeenCalledWith({
        where: { user: { id: mockUser.id } },
      });
    });
  });

  describe("manualSync", () => {
    it("should run sync and trigger SSE events on successful jobs", async () => {
      (Sync.findOne as jest.Mock).mockResolvedValue(null);
      mockProviderSyncJob.syncUserAllProviders.mockResolvedValue([{ status: "complete" }]);

      await controller.manualSync(mockUser, false);

      expect(Sync.findOne).toHaveBeenCalled();
      expect(mockProviderSyncJob.syncUserAllProviders).toHaveBeenCalledWith(mockUser);
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.SYNC);
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
    });

    it("should run sync and trigger only SYNC SSE event on failed jobs", async () => {
      (Sync.findOne as jest.Mock).mockResolvedValue(null);
      mockProviderSyncJob.syncUserAllProviders.mockResolvedValue([{ status: "failed" }]);

      await controller.manualSync(mockUser, false);

      expect(Sync.findOne).toHaveBeenCalled();
      expect(mockProviderSyncJob.syncUserAllProviders).toHaveBeenCalledWith(mockUser);
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.SYNC);
      expect(sseService.sendToUser).not.toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
    });

    it("should filter out undefined/null job results", async () => {
      (Sync.findOne as jest.Mock).mockResolvedValue(null);
      mockProviderSyncJob.syncUserAllProviders.mockResolvedValue([null]);

      await controller.manualSync(mockUser, false);

      expect(Sync.findOne).toHaveBeenCalled();
      expect(mockProviderSyncJob.syncUserAllProviders).toHaveBeenCalledWith(mockUser);
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.SYNC);
      expect(sseService.sendToUser).not.toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
    });

    it("should throw InternalServerErrorException if sync is already running and force is false", async () => {
      (Sync.findOne as jest.Mock).mockResolvedValue({ status: "in-progress" });

      await expect(controller.manualSync(mockUser, false)).rejects.toThrow(InternalServerErrorException);
      expect(mockProviderSyncJob.syncUserAllProviders).not.toHaveBeenCalled();
    });

    it("should force a manual sync even if a sync is already running when force is true", async () => {
      (Sync.findOne as jest.Mock).mockResolvedValue({ status: "in-progress" });
      mockProviderSyncJob.syncUserAllProviders.mockResolvedValue([{ status: "complete" }]);

      await controller.manualSync(mockUser, true);

      expect(Sync.findOne).toHaveBeenCalled();
      expect(mockProviderSyncJob.syncUserAllProviders).toHaveBeenCalledWith(mockUser);
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.SYNC);
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
    });
  });

  describe("mergeAccounts", () => {
    it("should successfully merge two accounts and trigger SSE", async () => {
      // Mock finding both accounts
      (Account.findOne as jest.Mock).mockResolvedValueOnce(mockAccount).mockResolvedValueOnce(mockSourceAccount);

      const request = { sourceId: "acc-2" } as any;

      const result = await controller.mergeAccounts("acc-1", request, mockUser);

      expect(Account.findOne).toHaveBeenCalledTimes(2);
      expect(AccountHistory.insertForNewAccount).toHaveBeenCalledWith(mockAccount, true);
      expect(mockTransactionManager.remove).toHaveBeenCalledWith(mockSourceAccount);
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
      expect(result).toEqual(mockAccount);
    });

    it("should update target subType if null and source has one", async () => {
      const targetWithoutSubType = { ...mockAccount, subType: null } as unknown as Account;
      (Account.findOne as jest.Mock).mockResolvedValueOnce(targetWithoutSubType).mockResolvedValueOnce(mockSourceAccount);

      const request = { sourceId: "acc-2" } as any;

      await controller.mergeAccounts("acc-1", request, mockUser);

      expect(targetWithoutSubType.subType).toBe(mockSourceAccount.subType);
      expect(mockTransactionManager.save).toHaveBeenCalledWith(targetWithoutSubType);
    });

    it("should throw BadRequestException if targetId and sourceId are the same", async () => {
      const request = { sourceId: "acc-1" } as any;

      await expect(controller.mergeAccounts("acc-1", request, mockUser)).rejects.toThrow(BadRequestException);
      expect(Account.findOne).not.toHaveBeenCalled();
    });

    it("should throw NotFoundException if one or both accounts do not exist", async () => {
      // Target exists, source does not
      (Account.findOne as jest.Mock).mockResolvedValueOnce(mockAccount).mockResolvedValueOnce(null);

      const request = { sourceId: "acc-2" } as any;

      await expect(controller.mergeAccounts("acc-1", request, mockUser)).rejects.toThrow(NotFoundException);
    });

    it("should throw BadRequestException if accounts are of different types", async () => {
      const creditSourceAccount = { ...mockSourceAccount, type: AccountType.credit } as unknown as Account;
      (Account.findOne as jest.Mock)
        .mockResolvedValueOnce(mockAccount) // DEPOSITORY
        .mockResolvedValueOnce(creditSourceAccount);

      const request = { sourceId: "acc-2" } as any;

      await expect(controller.mergeAccounts("acc-1", request, mockUser)).rejects.toThrow(BadRequestException);
    });
  });
});
