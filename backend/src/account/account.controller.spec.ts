import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { AccountController } from "@backend/account/account.controller.js";
import { AccountHistory } from "@backend/account/model/account.history.model.js";
import { Account } from "@backend/account/model/account.model.js";
import { AccountType } from "@backend/account/model/account.type.js";
import { Institution } from "@backend/institution/model/institution.model.js";
import { ProviderType } from "@backend/providers/base/provider.type.js";
import { PlaidProviderService } from "@backend/providers/plaid/plaid.provider.service.js";
import { SSEEventType } from "@backend/sse/model/event.model.js";
import { SSEService } from "@backend/sse/sse.service.js";
import { User } from "@backend/user/model/user.model.js";
import { BadRequestException, InternalServerErrorException, NotFoundException } from "@nestjs/common";

describe("AccountController", () => {
  let controller: AccountController;
  let sseService: Mocked<SSEService>;
  let databaseService: any;
  let plaidProvider: Mocked<PlaidProviderService>;
  let mockUser: User;

  beforeEach(() => {
    vi.restoreAllMocks();

    sseService = {
      sendToUser: vi.fn(),
    } as any;

    databaseService = {
      source: {
        transaction: vi.fn(),
      },
    };

    plaidProvider = {
      config: { dbType: ProviderType.plaid },
      unlinkInstitution: vi.fn(),
    } as any;

    mockUser = User.fromPlain({ id: "user-123" });

    controller = new AccountController(sseService, databaseService, [plaidProvider]);
  });

  describe("getById", () => {
    it("should return the account when it exists and belongs to the user", async () => {
      const mockAccount = Account.fromPlain({ id: "acc-1", name: "Savings" });
      const findOneSpy = vi.spyOn(Account, "findOne").mockResolvedValue(mockAccount);

      const result = await controller.getById("acc-1", mockUser);

      expect(findOneSpy).toHaveBeenCalledWith({
        where: { id: "acc-1", user: { id: "user-123" } },
      });
      expect(result).toBe(mockAccount);
    });

    it("should throw NotFoundException when the account does not exist", async () => {
      vi.spyOn(Account, "findOne").mockResolvedValue(null);

      await expect(controller.getById("acc-invalid", mockUser)).rejects.toThrow(NotFoundException);
    });
  });

  describe("delete", () => {
    it("should throw NotFoundException if account to delete is not found", async () => {
      vi.spyOn(Account, "findOne").mockResolvedValue(null);

      await expect(controller.delete("acc-invalid", mockUser)).rejects.toThrow(NotFoundException);
    });

    it("should throw InternalServerErrorException if delete action affects 0 records", async () => {
      const mockAccount = Account.fromPlain({ id: "acc-1", institution: { id: "inst-1" }, provider: "manual" });
      vi.spyOn(Account, "findOne").mockResolvedValue(mockAccount);
      vi.spyOn(Account, "deleteById").mockResolvedValue({ affected: 0 } as any);

      await expect(controller.delete("acc-1", mockUser)).rejects.toThrow(InternalServerErrorException);
    });

    it("should delete account, skip institution cleanup if accounts remain, and push notification", async () => {
      const mockInstitution = Institution.fromPlain({ id: "inst-1", name: "Bank" });
      const mockAccount = Account.fromPlain({ id: "acc-1", institution: mockInstitution, provider: "manual" });

      vi.spyOn(Account, "findOne").mockResolvedValue(mockAccount);
      vi.spyOn(Account, "deleteById").mockResolvedValue({ affected: 1 } as any);
      vi.spyOn(Account, "count").mockResolvedValue(2);

      const result = await controller.delete("acc-1", mockUser);

      expect(Account.deleteById).toHaveBeenCalledWith("acc-1");
      expect(Account.count).toHaveBeenCalledWith({ where: { institution: { id: "inst-1" } } });
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
      expect(result).toBe("Account with ID acc-1 deleted successfully.");
    });

    it("should clean up regular institution if 0 remaining accounts are left", async () => {
      const mockInstitution = Institution.fromPlain({ id: "inst-1", name: "Bank" });
      const mockAccount = Account.fromPlain({ id: "acc-1", institution: mockInstitution, provider: "manual" });

      vi.spyOn(Account, "findOne").mockResolvedValue(mockAccount);
      vi.spyOn(Account, "deleteById").mockResolvedValue({ affected: 1 } as any);
      vi.spyOn(Account, "count").mockResolvedValue(0);
      const deleteInstitutionSpy = vi.spyOn(Institution, "delete").mockResolvedValue({} as any);

      await controller.delete("acc-1", mockUser);

      expect(deleteInstitutionSpy).toHaveBeenCalledWith({ id: "inst-1" });
      expect(plaidProvider.unlinkInstitution).not.toHaveBeenCalled();
    });

    it("should trigger plaid unlinking during institution cleanup if provider is plaid", async () => {
      const mockInstitution = Institution.fromPlain({ id: "inst-plaid", name: "Plaid Bank" });
      const mockAccount = Account.fromPlain({ id: "acc-1", institution: mockInstitution, provider: ProviderType.plaid });

      vi.spyOn(Account, "findOne").mockResolvedValue(mockAccount);
      vi.spyOn(Account, "deleteById").mockResolvedValue({ affected: 1 } as any);
      vi.spyOn(Account, "count").mockResolvedValue(0);
      vi.spyOn(Institution, "delete").mockResolvedValue({} as any);

      await controller.delete("acc-1", mockUser);

      expect(plaidProvider.unlinkInstitution).toHaveBeenCalledWith(mockUser, "inst-plaid");
      expect(Institution.delete).toHaveBeenCalledWith({ id: "inst-plaid" });
    });

    it("should bypass cleanup entirely if the account has no associated institution", async () => {
      const mockAccount = Account.fromPlain({ id: "acc-1", provider: "manual" });

      vi.spyOn(Account, "findOne").mockResolvedValue(mockAccount);
      vi.spyOn(Account, "deleteById").mockResolvedValue({ affected: 1 } as any);
      const countSpy = vi.spyOn(Account, "count");

      await controller.delete("acc-1", mockUser);

      expect(countSpy).not.toHaveBeenCalled();
    });
  });

  describe("edit", () => {
    it("should throw NotFoundException if account does not exist for editing", async () => {
      vi.spyOn(Account, "findOne").mockResolvedValue(null);

      await expect(controller.edit("acc-1", mockUser, { name: "Valid Name" })).rejects.toThrow(NotFoundException);
    });

    it("should throw BadRequestException if target name modification is shorter than 2 characters", async () => {
      const mockAccount = Account.fromPlain({ id: "acc-1" });
      vi.spyOn(Account, "findOne").mockResolvedValue(mockAccount);

      await expect(controller.edit("acc-1", mockUser, { name: "s" })).rejects.toThrow(BadRequestException);
    });

    it("should apply updates, save, and notify user when all fields are supplied perfectly", async () => {
      const mockAccount = Account.fromPlain({
        id: "acc-1",
        name: "Old Name",
        type: AccountType.depository,
        subType: null,
        interestRate: null,
      });
      mockAccount.update = vi.fn().mockResolvedValue({ id: "acc-1" });

      vi.spyOn(Account, "findOne").mockResolvedValue(mockAccount);

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
      mockAccount.update = vi.fn().mockResolvedValue({ id: "acc-1" });

      vi.spyOn(Account, "findOne").mockResolvedValue(mockAccount);

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
      const findSpy = vi.spyOn(Account, "find").mockResolvedValue(mockCollection);

      const result = await controller.getAccounts(mockUser);

      expect(findSpy).toHaveBeenCalledWith({ where: { user: { id: "user-123" } } });
      expect(result).toBe(mockCollection);
    });
  });

  describe("mergeAccounts", () => {
    it("should throw BadRequestException when trying to fuse an account with its own ID", async () => {
      await expect(controller.mergeAccounts("acc-same", { sourceId: "acc-same" }, mockUser)).rejects.toThrow(BadRequestException);
    });

    it("should throw NotFoundException when one or both accounts are missing from lookup", async () => {
      vi.spyOn(Account, "findOne").mockResolvedValueOnce(null);

      await expect(controller.mergeAccounts("acc-target", { sourceId: "acc-source" }, mockUser)).rejects.toThrow(NotFoundException);
    });

    it("should throw BadRequestException if target and source profiles maintain different core account types", async () => {
      const mockTarget = Account.fromPlain({ id: "acc-target", type: AccountType.depository });
      const mockSource = Account.fromPlain({ id: "acc-source", type: AccountType.credit });

      vi.spyOn(Account, "findOne").mockResolvedValueOnce(mockTarget).mockResolvedValueOnce(mockSource);

      await expect(controller.mergeAccounts("acc-target", { sourceId: "acc-source" }, mockUser)).rejects.toThrow(BadRequestException);
    });

    it("should execute transactional operations smoothly with source holdings migration", async () => {
      const mockInstitution = Institution.fromPlain({ id: "inst-src" });
      const mockTarget = Account.fromPlain({ id: "acc-target", type: AccountType.investment, subType: null });
      const mockSource = Account.fromPlain({
        id: "acc-source",
        type: AccountType.investment,
        subType: "brokerage" as any,
        interestRate: 3.5,
        extra: { foo: "bar" },
        institution: mockInstitution,
        provider: "manual",
      });

      vi.spyOn(Account, "findOne").mockResolvedValueOnce(mockTarget).mockResolvedValueOnce(mockSource);

      const mockQueryBuilder = {
        update: vi.fn().mockReturnThis(),
        delete: vi.fn().mockReturnThis(),
        from: vi.fn().mockReturnThis(),
        set: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        execute: vi.fn().mockResolvedValue({}),
      };

      const sourceHoldings = [
        { id: "sh-1", symbol: "AAPL" },
        { id: "sh-2", symbol: "GOOG" },
      ];
      const targetHoldings = [{ id: "th-1", symbol: "AAPL" }];

      const mockManager = {
        save: vi.fn().mockResolvedValue({}),
        createQueryBuilder: vi.fn().mockReturnValue(mockQueryBuilder),
        remove: vi.fn().mockResolvedValue({}),
        find: vi.fn().mockImplementation((entity: any, options: any) => {
          if (options?.where?.accountId === "acc-source") return Promise.resolve(sourceHoldings);
          return Promise.resolve(targetHoldings);
        }),
      };

      vi.spyOn(databaseService.source, "transaction").mockImplementation(async (cb: any) => await cb(mockManager));
      vi.spyOn(AccountHistory, "insertForNewAccount").mockResolvedValue({} as any);
      vi.spyOn(Account, "count").mockResolvedValue(0);
      vi.spyOn(Institution, "delete").mockResolvedValue({} as any);

      const result = await controller.mergeAccounts("acc-target", { sourceId: "acc-source" }, mockUser);

      expect(mockManager.save).toHaveBeenCalledWith(mockTarget);
      expect(mockTarget.subType).toBe("brokerage");
      expect(mockTarget.interestRate).toBe(3.5);
      expect(mockTarget.extra).toEqual({ foo: "bar" });
      expect(mockQueryBuilder.update).toHaveBeenCalled();
      expect(mockQueryBuilder.delete).toHaveBeenCalled();
      expect(AccountHistory.insertForNewAccount).toHaveBeenCalledWith(mockTarget, true);
      expect(mockManager.remove).toHaveBeenCalledWith(mockSource);
      expect(Institution.delete).toHaveBeenCalledWith({ id: "inst-src" });
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
      expect(result).toBe(mockTarget);
    });

    it("should retain preexisting subType on target account if both target and source carry subType values", async () => {
      const mockTarget = Account.fromPlain({ id: "acc-target", type: AccountType.depository, subType: "savings" as any });
      const mockSource = Account.fromPlain({ id: "acc-source", type: AccountType.depository, subType: "checking" as any });

      vi.spyOn(Account, "findOne").mockResolvedValueOnce(mockTarget).mockResolvedValueOnce(mockSource);

      const mockQueryBuilder = {
        update: vi.fn().mockReturnThis(),
        delete: vi.fn().mockReturnThis(),
        from: vi.fn().mockReturnThis(),
        set: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        execute: vi.fn().mockResolvedValue({}),
      };

      const mockManager = {
        save: vi.fn(),
        createQueryBuilder: vi.fn().mockReturnValue(mockQueryBuilder),
        remove: vi.fn(),
        find: vi.fn().mockResolvedValue([]),
      };

      vi.spyOn(databaseService.source, "transaction").mockImplementation(async (cb: any) => await cb(mockManager));
      vi.spyOn(AccountHistory, "insertForNewAccount").mockResolvedValue({} as any);
      vi.spyOn(Account, "count").mockResolvedValue(1);

      await controller.mergeAccounts("acc-target", { sourceId: "acc-source" }, mockUser);

      expect(mockManager.save).toHaveBeenCalled();
      expect(mockTarget.subType).toBe("savings");
    });
  });
});
