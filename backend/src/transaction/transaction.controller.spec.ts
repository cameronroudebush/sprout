import { setupTests } from "@backend/test/helpers";
setupTests();

import { TransactionController } from "@backend/transaction/transaction.controller";
import { TransactionService } from "@backend/transaction/transaction.service";
import { SSEService } from "@backend/sse/sse.service";
import { NotificationService } from "@backend/notification/notification.service";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { Category } from "@backend/category/model/category.model";
import { Account } from "@backend/account/model/account.model";
import { TestEntities } from "@backend/test/entities";
import { BadRequestException, NotFoundException } from "@nestjs/common";
import { SSEEventType } from "@backend/sse/model/event.model";

describe("TransactionController", () => {
  let controller: TransactionController;
  let transactionService: jest.Mocked<TransactionService>;
  let sseService: jest.Mocked<SSEService>;
  let notificationService: jest.Mocked<NotificationService>;
  const user = TestEntities.user;

  beforeEach(() => {
    jest.clearAllMocks();

    transactionService = {
      findSubscriptions: jest.fn(),
    } as any;

    sseService = {
      sendToUser: jest.fn(),
    } as any;

    notificationService = {
      notifyUser: jest.fn().mockResolvedValue({}),
    } as any;

    controller = new TransactionController(transactionService, sseService, notificationService);
  });

  describe("edit", () => {
    it("should throw NotFoundException if transaction to edit does not exist", async () => {
      jest.spyOn(Transaction, "findOne").mockResolvedValue(null);

      await expect(controller.edit("tx-invalid", user, {} as any)).rejects.toThrow(NotFoundException);
    });

    it("should throw BadRequestException if transaction is pending", async () => {
      const tx = TestEntities.transaction;
      tx.pending = true;
      jest.spyOn(Transaction, "findOne").mockResolvedValue(tx);

      await expect(controller.edit(tx.id, user, {} as any)).rejects.toThrow(BadRequestException);
    });

    it("should throw NotFoundException if categoryId does not exist for user", async () => {
      const tx = TestEntities.transaction;
      tx.pending = false;
      jest.spyOn(Transaction, "findOne").mockResolvedValue(tx);
      jest.spyOn(Category, "findOne").mockResolvedValue(null);

      await expect(controller.edit(tx.id, user, { categoryId: "cat-invalid" } as any)).rejects.toThrow(NotFoundException);
    });

    it("should update description and category, save, and force update SSE", async () => {
      const tx = TestEntities.transaction;
      tx.pending = false;
      tx.update = jest.fn().mockResolvedValue(tx);
      jest.spyOn(Transaction, "findOne").mockResolvedValue(tx);
      const cat = TestEntities.category;
      jest.spyOn(Category, "findOne").mockResolvedValue(cat);

      const res = await controller.edit(tx.id, user, { categoryId: cat.id, description: "New Desc" } as any);

      expect(tx.description).toBe("New Desc");
      expect(tx.category).toBe(cat);
      expect(tx.manuallyEdited).toBe(true);
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(res).toBe(tx);
    });
  });

  describe("delete", () => {
    it("should throw NotFoundException if transaction not found", async () => {
      jest.spyOn(Transaction, "findOne").mockResolvedValue(null);

      await expect(controller.delete("tx-invalid", user)).rejects.toThrow(NotFoundException);
    });

    it("should remove transaction and force update SSE", async () => {
      const tx = TestEntities.transaction;
      tx.remove = jest.fn().mockResolvedValue(tx);
      jest.spyOn(Transaction, "findOne").mockResolvedValue(tx);

      const msg = await controller.delete(tx.id, user);

      expect(tx.remove).toHaveBeenCalled();
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(msg).toContain(tx.id);
    });
  });

  describe("getByQuery", () => {
    it("should return transactions based on category, date, description filters", async () => {
      const txList = [TestEntities.transaction];
      jest.spyOn(Transaction, "find").mockResolvedValue(txList);

      const res = await controller.getByQuery(user, 0, 10, "acc-1", "unknown", "grocery", "2026-06-02");

      expect(Transaction.find).toHaveBeenCalled();
      expect(res).toBe(txList);
    });

    it("should throw NotFoundException if category filter id is invalid", async () => {
      jest.spyOn(Category, "findOne").mockResolvedValue(null);

      await expect(controller.getByQuery(user, 0, 10, undefined, "cat-invalid")).rejects.toThrow(NotFoundException);
    });
  });

  describe("subscriptions", () => {
    it("should call findSubscriptions on transactionService", async () => {
      transactionService.findSubscriptions.mockResolvedValue([]);

      const res = await controller.subscriptions(user);

      expect(transactionService.findSubscriptions).toHaveBeenCalledWith(user);
      expect(res).toEqual([]);
    });
  });

  describe("getTotal", () => {
    it("should count total transactions and breakdown by accounts if no filter given", async () => {
      jest.spyOn(Transaction, "count").mockResolvedValue(15);
      jest.spyOn(Account, "getForUser").mockResolvedValue([TestEntities.account]);

      const res = await controller.getTotal(user);

      expect(res.total).toBe(15);
      expect(res.accounts[TestEntities.account.id]).toBe(15);
    });
  });

  describe("removeDuplicates", () => {
    it("should return message if no duplicates found", async () => {
      jest.spyOn(Transaction, "find").mockResolvedValue([TestEntities.transaction]);

      const res = await controller.removeDuplicates(user);

      expect(res).toContain("No duplicate transactions");
      expect(notificationService.notifyUser).toHaveBeenCalled();
    });

    it("should remove duplicate transactions and merge category/extra if present", async () => {
      const tx1 = TestEntities.transaction;

      const tx2 = Transaction.fromPlain({
        id: "tx-2",
        amount: tx1.amount,
        posted: tx1.posted,
        account: tx1.account,
        categoryId: "cat-2",
        category: TestEntities.category,
      });

      jest.spyOn(Transaction, "find").mockResolvedValue([tx1, tx2]);
      jest.spyOn(Transaction, "upsertMany").mockResolvedValue([] as any);
      jest.spyOn(Transaction, "deleteMany").mockResolvedValue({ affected: 1 } as any);

      const res = await controller.removeDuplicates(user);

      expect(Transaction.deleteMany).toHaveBeenCalledWith(["tx-2"]);
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(res).toContain("removed 1 duplicate");
    });
  });
});
