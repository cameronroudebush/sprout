import { setupTests } from "@backend/test/helpers";
setupTests();

import { AccountController } from "@backend/account/account.controller";
import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountType } from "@backend/account/model/account.type";
import { Institution } from "@backend/institution/model/institution.model";
import { Sync } from "@backend/jobs/model/sync.model";
import { ProviderSyncOrchestratorJob } from "@backend/jobs/sync";
import { ProviderType } from "@backend/providers/base/provider.type";
import { PlaidProviderService } from "@backend/providers/plaid/plaid.provider.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { BadRequestException, InternalServerErrorException, NotFoundException } from "@nestjs/common";
import * as dateFns from "date-fns";

describe("AccountController", () => {
  let controller: AccountController;
  let sseService: jest.Mocked<SSEService>;
  let databaseService: any;
  let providerSyncOrchestrator: jest.Mocked<ProviderSyncOrchestratorJob>;
  let plaidProvider: jest.Mocked<PlaidProviderService>;
  let mockUser: User;

  beforeEach(() => {
    jest.clearAllMocks();

    sseService = {
      sendToUser: jest.fn(),
    } as any;

    databaseService = {
      source: {
        transaction: jest.fn(),
      },
    };

    providerSyncOrchestrator = {
      syncUserAllProviders: jest.fn(),
    } as any;

    plaidProvider = {
      unlinkInstitution: jest.fn(),
    } as any;

    mockUser = User.fromPlain({ id: "user-123" });

    controller = new AccountController(sseService, databaseService, providerSyncOrchestrator, plaidProvider);
  });

  describe("getById", () => {
    it("should return the account when it exists and belongs to the user", async () => {
      const mockAccount = Account.fromPlain({ id: "acc-1", name: "Savings" });
      const findOneSpy = jest.spyOn(Account, "findOne").mockResolvedValue(mockAccount);

      const result = await controller.getById("acc-1", mockUser);

      expect(findOneSpy).toHaveBeenCalledWith({
        where: { id: "acc-1", user: { id: "user-123" } },
      });
      expect(result).toBe(mockAccount);
    });

    it("should throw NotFoundException when the account does not exist", async () => {
      jest.spyOn(Account, "findOne").mockResolvedValue(null);

      await expect(controller.getById("acc-invalid", mockUser)).rejects.toThrow(NotFoundException);
    });
  });

  describe("delete", () => {
    it("should throw NotFoundException if account to delete is not found", async () => {
      jest.spyOn(Account, "findOne").mockResolvedValue(null);

      await expect(controller.delete("acc-invalid", mockUser)).rejects.toThrow(NotFoundException);
    });

    it("should throw InternalServerErrorException if delete action affects 0 records", async () => {
      const mockAccount = Account.fromPlain({ id: "acc-1", institution: { id: "inst-1" }, provider: "manual" });
      jest.spyOn(Account, "findOne").mockResolvedValue(mockAccount);
      jest.spyOn(Account, "deleteById").mockResolvedValue({ affected: 0 } as any);

      await expect(controller.delete("acc-1", mockUser)).rejects.toThrow(InternalServerErrorException);
    });

    it("should delete account, skip institution cleanup if accounts remain, and push notification", async () => {
      const mockInstitution = Institution.fromPlain({ id: "inst-1", name: "Bank" });
      const mockAccount = Account.fromPlain({ id: "acc-1", institution: mockInstitution, provider: "manual" });

      jest.spyOn(Account, "findOne").mockResolvedValue(mockAccount);
      jest.spyOn(Account, "deleteById").mockResolvedValue({ affected: 1 } as any);
      jest.spyOn(Account, "count").mockResolvedValue(2);

      const result = await controller.delete("acc-1", mockUser);

      expect(Account.deleteById).toHaveBeenCalledWith("acc-1");
      expect(Account.count).toHaveBeenCalledWith({ where: { institution: { id: "inst-1" } } });
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
      expect(result).toBe("Account with ID acc-1 deleted successfully.");
    });

    it("should clean up regular institution if 0 remaining accounts are left", async () => {
      const mockInstitution = Institution.fromPlain({ id: "inst-1", name: "Bank" });
      const mockAccount = Account.fromPlain({ id: "acc-1", institution: mockInstitution, provider: "manual" });

      jest.spyOn(Account, "findOne").mockResolvedValue(mockAccount);
      jest.spyOn(Account, "deleteById").mockResolvedValue({ affected: 1 } as any);
      jest.spyOn(Account, "count").mockResolvedValue(0);
      const deleteInstitutionSpy = jest.spyOn(Institution, "delete").mockResolvedValue({} as any);

      await controller.delete("acc-1", mockUser);

      expect(deleteInstitutionSpy).toHaveBeenCalledWith({ id: "inst-1" });
      expect(plaidProvider.unlinkInstitution).not.toHaveBeenCalled();
    });

    it("should trigger plaid unlinking during institution cleanup if provider is plaid", async () => {
      const mockInstitution = Institution.fromPlain({ id: "inst-plaid", name: "Plaid Bank" });
      const mockAccount = Account.fromPlain({ id: "acc-1", institution: mockInstitution, provider: ProviderType.plaid });

      jest.spyOn(Account, "findOne").mockResolvedValue(mockAccount);
      jest.spyOn(Account, "deleteById").mockResolvedValue({ affected: 1 } as any);
      jest.spyOn(Account, "count").mockResolvedValue(0);
      jest.spyOn(Institution, "delete").mockResolvedValue({} as any);

      await controller.delete("acc-1", mockUser);

      expect(plaidProvider.unlinkInstitution).toHaveBeenCalledWith(mockUser, "inst-plaid");
      expect(Institution.delete).toHaveBeenCalledWith({ id: "inst-plaid" });
    });

    it("should bypass cleanup entirely if the account has no associated institution", async () => {
      const mockAccount = Account.fromPlain({ id: "acc-1", provider: "manual" });

      jest.spyOn(Account, "findOne").mockResolvedValue(mockAccount);
      jest.spyOn(Account, "deleteById").mockResolvedValue({ affected: 1 } as any);
      const countSpy = jest.spyOn(Account, "count");

      await controller.delete("acc-1", mockUser);

      expect(countSpy).not.toHaveBeenCalled();
    });
  });

  describe("edit", () => {
    it("should throw NotFoundException if account does not exist for editing", async () => {
      jest.spyOn(Account, "findOne").mockResolvedValue(null);

      await expect(controller.edit("acc-1", mockUser, { name: "Valid Name" })).rejects.toThrow(NotFoundException);
    });

    it("should throw BadRequestException if target name modification is shorter than 5 characters", async () => {
      const mockAccount = Account.fromPlain({ id: "acc-1" });
      jest.spyOn(Account, "findOne").mockResolvedValue(mockAccount);

      await expect(controller.edit("acc-1", mockUser, { name: "shor" })).rejects.toThrow(BadRequestException);
    });

    it("should apply updates, save, and notify user when all fields are supplied perfectly", async () => {
      const mockAccount = Account.fromPlain({
        id: "acc-1",
        name: "Old Name",
        type: AccountType.depository,
        subType: null,
        interestRate: null,
      });
      mockAccount.update = jest.fn().mockResolvedValue({ id: "acc-1" });

      jest.spyOn(Account, "findOne").mockResolvedValue(mockAccount);

      const payload = {
        name: "  Brand New Name  ",
        type: AccountType.credit,
        subType: "checking" as any,
        interestRate: 4.5,
      };

      const result = await controller.edit("acc-1", mockUser, payload);

      expect(mockAccount.name).toBe("Brand New Name");
      expect(mockAccount.type).toBe(AccountType.credit);
      expect(mockAccount.subType).toBe("checking");
      expect(mockAccount.interestRate).toBe(4.5);
      expect(mockAccount.update).toHaveBeenCalled();
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
      expect(result).toEqual({ id: "acc-1" });
    });

    it("should preserve original attributes if payload parameters are omitted", async () => {
      const mockAccount = Account.fromPlain({
        id: "acc-1",
        name: "Preserved Name",
        type: AccountType.depository,
        subType: "savings",
        interestRate: 1.2,
      });
      mockAccount.update = jest.fn().mockResolvedValue({ id: "acc-1" });

      jest.spyOn(Account, "findOne").mockResolvedValue(mockAccount);

      await controller.edit("acc-1", mockUser, {});

      expect(mockAccount.name).toBe("Preserved Name");
      expect(mockAccount.type).toBe(AccountType.depository);
      expect(mockAccount.subType).toBe("savings");
      expect(mockAccount.interestRate).toBe(1.2);
    });
  });

  describe("getAccounts", () => {
    it("should yield all profiles linked to the current user reference", async () => {
      const mockCollection = [Account.fromPlain({ id: "1" }), Account.fromPlain({ id: "2" })];
      const findSpy = jest.spyOn(Account, "find").mockResolvedValue(mockCollection);

      const result = await controller.getAccounts(mockUser);

      expect(findSpy).toHaveBeenCalledWith({ where: { user: { id: "user-123" } } });
      expect(result).toBe(mockCollection);
    });
  });

  describe("manualSync", () => {
    it("should throw InternalServerErrorException if an active daily sync exists and force parameter is omitted", async () => {
      jest.useFakeTimers().setSystemTime(new Date("2026-06-02T10:00:00.000Z"));
      jest.spyOn(Sync, "findOne").mockResolvedValue(Sync.fromPlain({ id: "sync-1" }));

      await expect(controller.manualSync(mockUser)).rejects.toThrow(InternalServerErrorException);
      expect(dateFns.startOfDay).toHaveBeenCalled();

      jest.useRealTimers();
    });

    it("should proceed with synchronization regardless of active syncs if force flag is activated", async () => {
      jest.spyOn(Sync, "findOne").mockResolvedValue(Sync.fromPlain({ id: "sync-1" }));
      providerSyncOrchestrator.syncUserAllProviders.mockResolvedValue([]);

      await controller.manualSync(mockUser, true);

      expect(providerSyncOrchestrator.syncUserAllProviders).toHaveBeenCalledWith(mockUser, false);
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.SYNC);
    });

    it("should bypass active sync warning if no synchronization process is marked in-progress", async () => {
      jest.spyOn(Sync, "findOne").mockResolvedValue(null);
      providerSyncOrchestrator.syncUserAllProviders.mockResolvedValue([Sync.fromPlain({ status: "completed" })]);

      await controller.manualSync(mockUser, false);

      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.SYNC);
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
    });

    it("should suppress FORCE_UPDATE event broadcast if every sync outcome reports as failed", async () => {
      jest.spyOn(Sync, "findOne").mockResolvedValue(null);
      providerSyncOrchestrator.syncUserAllProviders.mockResolvedValue([Sync.fromPlain({ status: "failed" })]);

      await controller.manualSync(mockUser, false);

      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.SYNC);
      expect(sseService.sendToUser).not.toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
    });
  });

  describe("mergeAccounts", () => {
    it("should throw BadRequestException when trying to fuse an account with its own ID", async () => {
      await expect(controller.mergeAccounts("acc-same", { sourceId: "acc-same" }, mockUser)).rejects.toThrow(BadRequestException);
    });

    it("should throw NotFoundException when one or both accounts are missing from lookup", async () => {
      jest.spyOn(Account, "findOne").mockResolvedValueOnce(null);

      await expect(controller.mergeAccounts("acc-target", { sourceId: "acc-source" }, mockUser)).rejects.toThrow(NotFoundException);
    });

    it("should throw BadRequestException if target and source profiles maintain different core account types", async () => {
      const mockTarget = Account.fromPlain({ id: "acc-target", type: AccountType.depository });
      const mockSource = Account.fromPlain({ id: "acc-source", type: AccountType.credit });

      jest.spyOn(Account, "findOne").mockResolvedValueOnce(mockTarget).mockResolvedValueOnce(mockSource);

      await expect(controller.mergeAccounts("acc-target", { sourceId: "acc-source" }, mockUser)).rejects.toThrow(BadRequestException);
    });

    it("should execute transactional operations smoothly, update subType, merge history/entities, and do cleanup", async () => {
      const mockInstitution = Institution.fromPlain({ id: "inst-src" });
      const mockTarget = Account.fromPlain({ id: "acc-target", type: AccountType.depository, subType: null });
      const mockSource = Account.fromPlain({
        id: "acc-source",
        type: AccountType.depository,
        subType: "checking" as any,
        institution: mockInstitution,
        provider: "manual",
      });

      jest.spyOn(Account, "findOne").mockResolvedValueOnce(mockTarget).mockResolvedValueOnce(mockSource);

      const mockQueryBuilder = {
        update: jest.fn().mockReturnThis(),
        set: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        execute: jest.fn().mockResolvedValue({}),
      };

      const mockManager = {
        save: jest.fn().mockResolvedValue({}),
        createQueryBuilder: jest.fn().mockReturnValue(mockQueryBuilder),
        remove: jest.fn().mockResolvedValue({}),
      };

      jest.spyOn(databaseService.source, "transaction").mockImplementation(async (cb: any) => await cb(mockManager));
      jest.spyOn(AccountHistory, "insertForNewAccount").mockResolvedValue({} as any);
      jest.spyOn(Account, "count").mockResolvedValue(0);
      jest.spyOn(Institution, "delete").mockResolvedValue({} as any);

      const result = await controller.mergeAccounts("acc-target", { sourceId: "acc-source" }, mockUser);

      expect(mockManager.save).toHaveBeenCalledWith(mockTarget);
      expect(mockTarget.subType).toBe("checking");
      expect(mockQueryBuilder.update).toHaveBeenCalledTimes(4);
      expect(AccountHistory.insertForNewAccount).toHaveBeenCalledWith(mockTarget, true);
      expect(mockManager.remove).toHaveBeenCalledWith(mockSource);
      expect(Institution.delete).toHaveBeenCalledWith({ id: "inst-src" });
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
      expect(result).toBe(mockTarget);
    });

    it("should retain preexisting subType on target account if both target and source carry subType values", async () => {
      const mockTarget = Account.fromPlain({ id: "acc-target", type: AccountType.depository, subType: "savings" as any });
      const mockSource = Account.fromPlain({ id: "acc-source", type: AccountType.depository, subType: "checking" as any });

      jest.spyOn(Account, "findOne").mockResolvedValueOnce(mockTarget).mockResolvedValueOnce(mockSource);

      const mockQueryBuilder = {
        update: jest.fn().mockReturnThis(),
        set: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        execute: jest.fn().mockResolvedValue({}),
      };

      const mockManager = {
        save: jest.fn(),
        createQueryBuilder: jest.fn().mockReturnValue(mockQueryBuilder),
        remove: jest.fn(),
      };

      jest.spyOn(databaseService.source, "transaction").mockImplementation(async (cb: any) => await cb(mockManager));
      jest.spyOn(AccountHistory, "insertForNewAccount").mockResolvedValue({} as any);
      jest.spyOn(Account, "count").mockResolvedValue(1);

      await controller.mergeAccounts("acc-target", { sourceId: "acc-source" }, mockUser);

      expect(mockManager.save).not.toHaveBeenCalled();
      expect(mockTarget.subType).toBe("savings");
    });
  });
});
