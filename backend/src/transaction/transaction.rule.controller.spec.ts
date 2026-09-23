import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { Category } from "@backend/category/model/category.model.js";
import { SSEEventType } from "@backend/sse/model/event.model.js";
import { SSEService } from "@backend/sse/sse.service.js";
import { TestEntities } from "@backend/test/entities.js";
import { TransactionRule } from "@backend/transaction/model/transaction.rule.model.js";
import { TransactionRuleType } from "@backend/transaction/model/transaction.rule.type.js";
import { TransactionRuleController } from "@backend/transaction/transaction.rule.controller.js";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service.js";
import { BadRequestException, NotFoundException } from "@nestjs/common";
import { Mocked } from "vitest";

describe("TransactionRuleController", () => {
  let controller: TransactionRuleController;
  let sseService: Mocked<SSEService>;
  let transactionRuleService: Mocked<TransactionRuleService>;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.restoreAllMocks();

    sseService = {
      sendToUser: vi.fn(),
    } as any;

    transactionRuleService = {
      applyRulesToTransactions: vi.fn().mockResolvedValue(undefined),
      reorderRules: vi.fn().mockResolvedValue(undefined),
    } as any;

    controller = new TransactionRuleController(sseService, transactionRuleService);
  });

  describe("get", () => {
    it("should return transaction rules for user ordered by order ASC", async () => {
      const rules = [TestEntities.transactionRule];
      vi.spyOn(TransactionRule, "find").mockResolvedValue(rules);

      const res = await controller.get(user);

      expect(TransactionRule.find).toHaveBeenCalledWith({
        where: { user: { id: user.id } },
        order: { order: "ASC" },
        relations: { category: { parentCategory: true } },
      });
      expect(res).toBe(rules);
    });
  });

  describe("delete", () => {
    it("should throw NotFoundException if rule not found", async () => {
      vi.spyOn(TransactionRule, "findOne").mockResolvedValue(null);

      await expect(controller.delete("rule-invalid", user)).rejects.toThrow(NotFoundException);
    });

    it("should delete rule, re-apply rules to transactions, and force update SSE", async () => {
      const rule = TestEntities.transactionRule;
      vi.spyOn(TransactionRule, "findOne").mockResolvedValue(rule);
      vi.spyOn(TransactionRule, "deleteById").mockResolvedValue({} as any);

      const msg = await controller.delete(rule.id, user);

      expect(TransactionRule.deleteById).toHaveBeenCalledWith(rule.id);
      expect(transactionRuleService.applyRulesToTransactions).toHaveBeenCalledWith(user);
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(msg).toContain(rule.id);
    });
  });

  describe("edit", () => {
    it("should throw NotFoundException if matching rule not found", async () => {
      vi.spyOn(TransactionRule, "findOne").mockResolvedValue(null);

      await expect(controller.edit("rule-invalid", user, {} as any)).rejects.toThrow(NotFoundException);
    });

    it("should throw NotFoundException if categoryId provided does not exist", async () => {
      const rule = TestEntities.transactionRule;
      vi.spyOn(TransactionRule, "findOne").mockResolvedValue(rule);
      vi.spyOn(Category, "findOne").mockResolvedValue(null);

      const updatePayload = TransactionRule.fromPlain({
        categoryId: "cat-invalid",
        type: "description",
        value: "val",
      });

      await expect(controller.edit(rule.id, user, updatePayload)).rejects.toThrow(NotFoundException);
    });

    it("should throw BadRequestException if rule type is invalid", async () => {
      const rule = TestEntities.transactionRule;
      vi.spyOn(TransactionRule, "findOne").mockResolvedValue(rule);

      const updatePayload = TransactionRule.fromPlain({
        type: "invalid_type" as any,
        value: "val",
      });

      await expect(controller.edit(rule.id, user, updatePayload)).rejects.toThrow(BadRequestException);
    });

    it("should update rule without reordering if order is unchanged or omitted", async () => {
      const rule = TestEntities.transactionRule;
      rule.order = 1;
      vi.spyOn(TransactionRule, "findOne").mockResolvedValueOnce(rule).mockResolvedValueOnce(rule);

      const updatePayload = TransactionRule.fromPlain({
        type: TransactionRuleType.description,
        value: "Grocery",
        order: 1,
      });
      updatePayload.update = vi.fn().mockResolvedValue(updatePayload);

      await controller.edit(rule.id, user, updatePayload);

      expect(transactionRuleService.reorderRules).not.toHaveBeenCalled();
      expect(transactionRuleService.applyRulesToTransactions).toHaveBeenCalledWith(user);
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
    });

    it("should update rule, reorder if order changed, apply rules, and force update", async () => {
      const rule = TestEntities.transactionRule;
      rule.order = 1;
      vi.spyOn(TransactionRule, "findOne").mockResolvedValueOnce(rule).mockResolvedValueOnce(rule);

      const cat = TestEntities.category;
      vi.spyOn(Category, "findOne").mockResolvedValue(cat);

      const updatePayload = TransactionRule.fromPlain({
        type: TransactionRuleType.description,
        value: "Grocery",
        categoryId: cat.id,
        order: 2,
      });
      updatePayload.update = vi.fn().mockResolvedValue(updatePayload);

      const res = await controller.edit(rule.id, user, updatePayload);

      expect(transactionRuleService.reorderRules).toHaveBeenCalledWith(user, rule.id, 2);
      expect(transactionRuleService.applyRulesToTransactions).toHaveBeenCalledWith(user);
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(res).toBeDefined();
    });
  });

  describe("create", () => {
    it("should throw NotFoundException if categoryId does not exist", async () => {
      vi.spyOn(Category, "findOne").mockResolvedValue(null);

      const rule = TransactionRule.fromPlain({ value: "Test", categoryId: "cat-invalid" });

      await expect(controller.create(rule, user)).rejects.toThrow(NotFoundException);
    });

    it("should create rule without categoryId, set order, insert rule, apply rules, and force update", async () => {
      const categorySpy = vi.spyOn(Category, "findOne").mockResolvedValue(null);
      vi.spyOn(TransactionRule, "findOne").mockResolvedValue(null);

      const rule = TransactionRule.fromPlain({ value: "Grocery", categoryId: undefined });
      rule.insert = vi.fn().mockResolvedValue(rule);

      await controller.create(rule, user);

      expect(categorySpy).not.toHaveBeenCalled();
      expect(rule.order).toBe(0);
      expect(rule.value).toBe("Grocery");
      expect(transactionRuleService.applyRulesToTransactions).toHaveBeenCalledWith(user);
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
    });

    it("should set order +1 when prior rules exist, insert rule, apply rules, and force update", async () => {
      const cat = TestEntities.category;
      vi.spyOn(Category, "findOne").mockResolvedValue(cat);
      const lastRule = TransactionRule.fromPlain({ order: 5 });

      vi.spyOn(TransactionRule, "findOne").mockResolvedValue(lastRule);

      const inputData = { value: "Grocery", categoryId: cat.id } as any;

      const ruleMockInstance = {
        value: "Grocery",
        user,
        categoryId: cat.id,
        order: 0,
        insert: vi.fn().mockResolvedValue(undefined),
      };

      vi.spyOn(TransactionRule, "fromPlain").mockReturnValue(ruleMockInstance as any);

      await controller.create(inputData, user);

      expect(ruleMockInstance.order).toBe(6);
      expect(ruleMockInstance.value).toBe("Grocery");
      expect(transactionRuleService.applyRulesToTransactions).toHaveBeenCalledWith(user);
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
    });
  });

  describe("applyRules", () => {
    it("should call transactionRuleService.applyRulesToTransactions and force update", async () => {
      await controller.applyRules(user, true, false);

      expect(transactionRuleService.applyRulesToTransactions).toHaveBeenCalledWith(user, undefined, undefined, true, false);
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
    });
  });
});
