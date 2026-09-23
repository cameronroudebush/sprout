import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { Account } from "@backend/account/model/account.model.js";
import { Category } from "@backend/category/model/category.model.js";
import { NotificationService } from "@backend/notification/notification.service.js";
import { SSEEventType } from "@backend/sse/model/event.model.js";
import { SSEService } from "@backend/sse/sse.service.js";
import { TestEntities } from "@backend/test/entities.js";
import { Transaction } from "@backend/transaction/model/transaction.model.js";
import { TransactionController } from "@backend/transaction/transaction.controller.js";
import { TransactionService } from "@backend/transaction/transaction.service.js";
import { BadRequestException, NotFoundException } from "@nestjs/common";
import { Mocked } from "vitest";

describe("TransactionController", () => {
  let controller: TransactionController;
  let transactionService: Mocked<TransactionService>;
  let sseService: Mocked<SSEService>;
  let notificationService: Mocked<NotificationService>;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.restoreAllMocks();

    transactionService = {
      findSubscriptions: vi.fn(),
    } as any;

    sseService = {
      sendToUser: vi.fn(),
    } as any;

    notificationService = {
      notifyUser: vi.fn().mockResolvedValue({}),
    } as any;

    controller = new TransactionController(transactionService, sseService, notificationService);
  });

  describe("edit", () => {
    it("should throw NotFoundException if transaction to edit does not exist", async () => {
      vi.spyOn(Transaction, "findOne").mockResolvedValue(null);

      await expect(controller.edit("tx-invalid", user, {} as any)).rejects.toThrow(NotFoundException);
    });

    it("should throw BadRequestException if transaction is pending", async () => {
      const tx = TestEntities.transaction;
      tx.pending = true;
      vi.spyOn(Transaction, "findOne").mockResolvedValue(tx);

      await expect(controller.edit(tx.id, user, {} as any)).rejects.toThrow(BadRequestException);
    });

    it("should throw NotFoundException if categoryId does not exist for user", async () => {
      const tx = TestEntities.transaction;
      tx.pending = false;
      vi.spyOn(Transaction, "findOne").mockResolvedValue(tx);
      vi.spyOn(Category, "findOne").mockResolvedValue(null);

      await expect(controller.edit(tx.id, user, { categoryId: "cat-invalid" } as any)).rejects.toThrow(NotFoundException);
    });

    it("should update description and category, save, and force update SSE", async () => {
      const tx = TestEntities.transaction;
      tx.pending = false;
      tx.update = vi.fn().mockResolvedValue(tx);
      vi.spyOn(Transaction, "findOne").mockResolvedValue(tx);
      const cat = TestEntities.category;
      vi.spyOn(Category, "findOne").mockResolvedValue(cat);

      const res = await controller.edit(tx.id, user, {
        categoryId: cat.id,
        description: "New Desc",
      } as any);

      expect(tx.description).toBe("New Desc");
      expect(tx.category).toBe(cat);
      expect(tx.manuallyEdited).toBe(true);
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(res).toBe(tx);
    });

    it("should preserve description when description is omitted from update body", async () => {
      const tx = TestEntities.transaction;
      tx.description = "Original Description";
      tx.pending = false;
      tx.update = vi.fn().mockResolvedValue(tx);
      vi.spyOn(Transaction, "findOne").mockResolvedValue(tx);

      const res = await controller.edit(tx.id, user, {} as any);

      expect(tx.description).toBe("Original Description");
      expect(res).toBe(tx);
    });

    it("should set category to null and manuallyEdited to false when categoryId is 'unknown'", async () => {
      const tx = TestEntities.transaction;
      tx.pending = false;
      tx.category = TestEntities.category;
      tx.manuallyEdited = true;
      tx.update = vi.fn().mockResolvedValue(tx);
      vi.spyOn(Transaction, "findOne").mockResolvedValue(tx);

      const res = await controller.edit(tx.id, user, {
        categoryId: "unknown",
      } as any);

      expect(tx.category).toBeNull();
      expect(tx.manuallyEdited).toBe(false);
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(res).toBe(tx);
    });
  });

  describe("delete", () => {
    it("should throw NotFoundException if transaction not found", async () => {
      vi.spyOn(Transaction, "findOne").mockResolvedValue(null);

      await expect(controller.delete("tx-invalid", user)).rejects.toThrow(NotFoundException);
    });

    it("should remove transaction and force update SSE", async () => {
      const tx = TestEntities.transaction;
      tx.remove = vi.fn().mockResolvedValue(tx);
      vi.spyOn(Transaction, "findOne").mockResolvedValue(tx);

      const msg = await controller.delete(tx.id, user);

      expect(tx.remove).toHaveBeenCalled();
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(msg).toContain(tx.id);
    });
  });

  describe("getByQuery", () => {
    it("should return transactions directly by ID", async () => {
      const txList = [TestEntities.transaction];
      vi.spyOn(Transaction, "find").mockResolvedValue(txList);

      const res = await controller.getByQuery(user, "tx-123");

      expect(Transaction.find).toHaveBeenCalledWith({
        where: { id: "tx-123", account: { user: { id: user.id } } },
        relations: { category: { parentCategory: true } },
      });
      expect(res).toBe(txList);
    });

    it("should return transactions filtered by category ID with children categories", async () => {
      const parentCat = Category.fromPlain({ id: "cat-parent" });
      const childCat = Category.fromPlain({ id: "cat-child" });

      vi.spyOn(Category, "findOne").mockResolvedValue(parentCat);
      vi.spyOn(Category, "find").mockResolvedValueOnce([childCat]).mockResolvedValueOnce([]);
      vi.spyOn(Transaction, "find").mockResolvedValue([TestEntities.transaction]);

      const res = await controller.getByQuery(user, undefined, 0, 10, "acc-1", "cat-parent", "grocery", undefined, "2026-01-01", "2026-01-31", true);

      expect(res).toBeDefined();
    });

    it("should return transactions based on category, date, description filters", async () => {
      const txList = [TestEntities.transaction];
      vi.spyOn(Transaction, "find").mockResolvedValue(txList);

      const res = await controller.getByQuery(user, "", 0, 10, "acc-1", "unknown", "grocery", "2026-06-02");

      expect(Transaction.find).toHaveBeenCalled();
      expect(res).toBe(txList);
    });

    it("should handle single pagination index params (startIndex only or endIndex only)", async () => {
      vi.spyOn(Transaction, "find").mockResolvedValue([TestEntities.transaction]);

      const res1 = await controller.getByQuery(user, undefined, 5, undefined);
      expect(res1).toBeDefined();

      const res2 = await controller.getByQuery(user, undefined, undefined, 10);
      expect(res2).toBeDefined();
    });

    it("should throw NotFoundException if category filter id is invalid", async () => {
      vi.spyOn(Category, "findOne").mockResolvedValue(null);

      await expect(controller.getByQuery(user, "", 0, 10, undefined, "cat-invalid")).rejects.toThrow(NotFoundException);
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
      vi.spyOn(Transaction, "count").mockResolvedValue(15);
      vi.spyOn(Account, "getForUser").mockResolvedValue([TestEntities.account]);

      const res = await controller.getTotal(user);

      expect(res.total).toBe(15);
      expect(res.accounts[TestEntities.account.id]).toBe(15);
    });

    it("should count total transactions with accountId, category, and description filters", async () => {
      vi.spyOn(Transaction, "count").mockResolvedValue(5);

      const res1 = await controller.getTotal(user, "acc-1", "unknown", "grocery");
      expect(res1.total).toBe(5);

      const res2 = await controller.getTotal(user, undefined, "cat-1", "grocery");
      expect(res2.total).toBe(5);
    });
  });

  describe("removeDuplicates", () => {
    it("should return message if no duplicates found", async () => {
      vi.spyOn(Transaction, "find").mockResolvedValue([TestEntities.transaction]);

      const res = await controller.removeDuplicates(user);

      expect(res).toContain("No duplicate transactions");
      expect(notificationService.notifyUser).toHaveBeenCalled();
    });

    it("should remove duplicate transactions and merge category/extra if present, swapping providerId when needed", async () => {
      const account = TestEntities.account;
      vi.spyOn(Account, "findOne").mockResolvedValue(account);

      const txKeptNoProvider = Transaction.fromPlain({
        id: "tx-kept",
        amount: 50.0,
        posted: new Date("2026-01-01T10:00:00Z"),
        providerId: undefined,
        account,
        extra: { logoUrl: "http://logo.png" },
      });

      const txRemoveWithProvider = Transaction.fromPlain({
        id: "tx-remove",
        amount: 50.0,
        posted: new Date("2026-01-01T12:00:00Z"),
        providerId: "prov-123",
        account,
        categoryId: "cat-1",
        category: TestEntities.category,
        extra: { merchantName: "Coffee Shop", logoUrl: "http://other-logo.png" },
      });

      vi.spyOn(Transaction, "find").mockResolvedValue([txKeptNoProvider, txRemoveWithProvider]);
      vi.spyOn(Transaction, "upsertMany").mockResolvedValue([] as any);
      vi.spyOn(Transaction, "deleteMany").mockResolvedValue({ affected: 1 } as any);

      const res = await controller.removeDuplicates(user, account.id);

      expect(Transaction.deleteMany).toHaveBeenCalled();
      expect(Transaction.upsertMany).toHaveBeenCalled();
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(res).toContain("Successfully removed 1 duplicate transaction from");
    });

    it("should format pluralized response message when multiple duplicates are removed", async () => {
      const account = TestEntities.account;
      vi.spyOn(Account, "findOne").mockResolvedValue(account);

      const txKept = Transaction.fromPlain({
        id: "tx-kept-plural",
        amount: 100.0,
        posted: new Date("2026-01-01T10:00:00Z"),
        account,
      });

      const txDup1 = Transaction.fromPlain({
        id: "tx-dup-1",
        amount: 100.0,
        posted: new Date("2026-01-01T11:00:00Z"),
        account,
      });

      const txDup2 = Transaction.fromPlain({
        id: "tx-dup-2",
        amount: 100.0,
        posted: new Date("2026-01-01T12:00:00Z"),
        account,
      });

      vi.spyOn(Transaction, "find").mockResolvedValue([txKept, txDup1, txDup2]);
      vi.spyOn(Transaction, "upsertMany").mockResolvedValue([] as any);
      vi.spyOn(Transaction, "deleteMany").mockResolvedValue({ affected: 2 } as any);

      const res = await controller.removeDuplicates(user, account.id);

      expect(res).toContain("Successfully removed 2 duplicate transactions from");
    });

    it("should inherit providerId when kept transaction lacks it and swap is not triggered", async () => {
      const account = TestEntities.account;
      vi.spyOn(Account, "findOne").mockResolvedValue(account);

      // Duplicate #1 (kept initially, no providerId)
      const txKept = Transaction.fromPlain({
        id: "tx-kept-no-prov",
        amount: 85.0,
        posted: new Date("2026-01-01T10:00:00Z"),
        providerId: undefined,
        account,
      });

      // Duplicate #2 (has providerId -> triggers swap, so txRemove becomes kept)
      const txRemove = Transaction.fromPlain({
        id: "tx-swap-prov",
        amount: 85.0,
        posted: new Date("2026-01-01T11:00:00Z"),
        providerId: "prov-alpha",
        account,
        extra: undefined,
      });

      // Duplicate #3 (has extra data -> inherits extra onto kept transaction without swapping providerId)
      const txDup3 = Transaction.fromPlain({
        id: "tx-dup-3",
        amount: 85.0,
        posted: new Date("2026-01-01T12:00:00Z"),
        providerId: "prov-beta",
        account,
        extra: { merchantName: "Inherited Merchant" },
      });

      vi.spyOn(Transaction, "find").mockResolvedValue([txKept, txRemove, txDup3]);
      vi.spyOn(Transaction, "upsertMany").mockResolvedValue([] as any);
      vi.spyOn(Transaction, "deleteMany").mockResolvedValue({ affected: 2 } as any);

      const res = await controller.removeDuplicates(user, account.id);

      expect(res).toContain("Successfully removed 2 duplicate transactions");
      expect(Transaction.upsertMany).toHaveBeenCalled();
    });

    it("should handle duplicate removal when extra is merged with different non-conflicting properties", async () => {
      const account = TestEntities.account;
      vi.spyOn(Account, "findOne").mockResolvedValue(account);

      const txKept = Transaction.fromPlain({
        id: "tx-kept-2",
        amount: 30.0,
        posted: new Date("2026-01-01T10:00:00Z"),
        providerId: "prov-1",
        account,
        categoryId: "cat-1",
        extra: { merchantName: "Grocery Store" },
      });

      const txDup1 = Transaction.fromPlain({
        id: "tx-dup-1",
        amount: 30.0,
        posted: new Date("2026-01-01T11:00:00Z"),
        providerId: undefined,
        account,
        extra: { logoUrl: "http://logo.png" },
      });

      vi.spyOn(Transaction, "find").mockResolvedValue([txKept, txDup1]);
      vi.spyOn(Transaction, "upsertMany").mockResolvedValue([] as any);
      vi.spyOn(Transaction, "deleteMany").mockResolvedValue({ affected: 1 } as any);

      const res = await controller.removeDuplicates(user, account.id);

      expect(res).toContain("Successfully removed 1 duplicate transaction from");
      expect(Transaction.upsertMany).toHaveBeenCalled();
    });

    it("should inherit category from duplicate when kept transaction already has provider", async () => {
      const account = TestEntities.account;
      vi.spyOn(Account, "findOne").mockResolvedValue(account);
      const kept = Transaction.fromPlain({
        id: "tx-category-kept",
        amount: 40,
        posted: new Date("2026-01-01T10:00:00Z"),
        providerId: "provider-kept",
        account,
      });
      const duplicate = Transaction.fromPlain({
        id: "tx-category-duplicate",
        amount: 40,
        posted: new Date("2026-01-01T11:00:00Z"),
        account,
        categoryId: "category-inherited",
        category: TestEntities.category,
      });
      vi.spyOn(Transaction, "find").mockResolvedValue([kept, duplicate]);
      vi.spyOn(Transaction, "upsertMany").mockResolvedValue([] as any);
      vi.spyOn(Transaction, "deleteMany").mockResolvedValue({ affected: 1 } as any);

      await controller.removeDuplicates(user, account.id);

      expect(Transaction.upsertMany).toHaveBeenCalled();
      expect(kept.category?.id).toBe(TestEntities.category.id);
    });

    it("should handle duplicates without extra data and use duplicate count fallback", async () => {
      const account = TestEntities.account;
      vi.spyOn(Account, "findOne").mockResolvedValue(account);
      const kept = Transaction.fromPlain({
        id: "tx-no-extra-kept",
        amount: 41,
        posted: new Date("2026-01-01T10:00:00Z"),
        account,
        providerId: "provider",
        extra: { source: "same" },
      });
      const duplicate = Transaction.fromPlain({
        id: "tx-no-extra-duplicate",
        amount: 41,
        posted: new Date("2026-01-01T11:00:00Z"),
        account,
        providerId: undefined,
        extra: { source: "same" },
      });
      vi.spyOn(Transaction, "find").mockResolvedValue([kept, duplicate]);
      vi.spyOn(Transaction, "upsertMany").mockResolvedValue([] as any);
      vi.spyOn(Transaction, "deleteMany").mockResolvedValue({} as any);

      const result = await controller.removeDuplicates(user, account.id);

      expect(result).toContain("Successfully removed 1 duplicate transaction");
      expect(Transaction.upsertMany).not.toHaveBeenCalled();
    });

    it("should inherit a provider id when it becomes available after the initial duplicate check", async () => {
      const account = TestEntities.account;
      vi.spyOn(Account, "findOne").mockResolvedValue(account);

      const kept = Transaction.fromPlain({ id: "tx-late-kept", amount: 77, posted: new Date("2026-01-01T10:00:00Z"), account });
      const duplicate = Transaction.fromPlain({ id: "tx-late-dup", amount: 77, posted: new Date("2026-01-01T11:00:00Z"), account });

      let keptProviderId: string | undefined;
      Object.defineProperty(kept, "providerId", {
        get: () => keptProviderId,
        set: (value: string) => {
          keptProviderId = value;
        },
        configurable: true,
      });
      let providerIdReads = 0;
      Object.defineProperty(duplicate, "providerId", {
        get: () => (providerIdReads++ === 0 ? undefined : "prov-late"),
        set: () => {},
        configurable: true,
      });

      vi.spyOn(Transaction, "find").mockResolvedValue([kept, duplicate]);
      vi.spyOn(Transaction, "upsertMany").mockResolvedValue([] as any);
      vi.spyOn(Transaction, "deleteMany").mockResolvedValue({ affected: 1 } as any);

      const result = await controller.removeDuplicates(user, account.id);

      expect(keptProviderId).toBe("prov-late");
      expect(Transaction.upsertMany).toHaveBeenCalled();
      expect(result).toContain("Successfully removed 1 duplicate transaction");
    });
  });
});
