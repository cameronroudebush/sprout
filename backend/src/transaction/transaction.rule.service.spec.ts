import { setupTests } from "@backend/test/helpers";
setupTests();

import { TestEntities } from "@backend/test/entities";
import { TransactionRule } from "@backend/transaction/model/transaction.rule.model";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";

describe("TransactionRuleService", () => {
  let service: TransactionRuleService;
  const user = TestEntities.user;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new TransactionRuleService();
  });

  describe("applyRulesToTransactions", () => {
    it("should fetch rules and apply description matching rules to transactions", async () => {
      const rule = TransactionRule.fromPlain({
        id: "r-1",
        user,
        enabled: true,
        type: "description",
        strict: false,
        value: "starbucks|coffee",
        matches: 0,
        category: TestEntities.category,
      });

      const tx = TestEntities.transaction;
      tx.description = "Morning Starbucks";
      tx.update = jest.fn().mockResolvedValue(tx);
      rule.update = jest.fn().mockResolvedValue(rule);

      jest.spyOn(TransactionRule, "find").mockResolvedValue([rule]);
      jest.spyOn(require("@backend/transaction/model/transaction.model").Transaction, "find").mockResolvedValue([tx]);

      await service.applyRulesToTransactions(user);

      expect(tx.update).toHaveBeenCalled();
      expect(rule.update).toHaveBeenCalled();
    });

    it("should handle description strict matching, amount matching, and resetCategories option", async () => {
      const strictRule = TransactionRule.fromPlain({
        id: "r-2",
        user,
        enabled: true,
        type: "description",
        strict: true,
        value: "Exact Match",
        matches: 0,
        category: TestEntities.category,
      });

      const amountRule = TransactionRule.fromPlain({
        id: "r-3",
        user,
        enabled: true,
        type: "amount",
        value: "25.50",
        matches: 0,
        category: TestEntities.category,
      });

      const tx1 = TestEntities.transaction;
      tx1.id = "tx-1";
      tx1.description = "Exact Match";
      tx1.update = jest.fn().mockResolvedValue(tx1);

      const tx2 = TestEntities.transaction;
      tx2.id = "tx-2";
      tx2.description = "No Match";
      tx2.amount = 25.5;
      tx2.update = jest.fn().mockResolvedValue(tx2);

      const txUnmatched = TestEntities.transaction;
      txUnmatched.id = "tx-3";
      txUnmatched.description = "Unmatched";
      txUnmatched.amount = 100;
      txUnmatched.category = TestEntities.category;
      txUnmatched.update = jest.fn().mockResolvedValue(txUnmatched);

      strictRule.update = jest.fn().mockResolvedValue(strictRule);
      amountRule.update = jest.fn().mockResolvedValue(amountRule);

      jest.spyOn(TransactionRule, "find").mockResolvedValue([strictRule, amountRule]);
      jest.spyOn(require("@backend/transaction/model/transaction.model").Transaction, "find").mockResolvedValue([tx1, tx2, txUnmatched]);

      await service.applyRulesToTransactions(user, undefined, false, false, true);

      expect(txUnmatched.category).toBeUndefined();
      expect(txUnmatched.update).toHaveBeenCalled();
    });
  });

  describe("reorderRules", () => {
    it("should slide overlapping rules and return updated list", async () => {
      const rule1 = TransactionRule.fromPlain({ id: "r-10", order: 1, user, update: jest.fn() });
      const rule2 = TransactionRule.fromPlain({ id: "r-20", order: 2, user, update: jest.fn() });

      jest.spyOn(TransactionRule, "find").mockImplementation(async (opts: any) => {
        if (opts.where && opts.where.order) return [rule2];
        return [rule1, rule2];
      });

      const result = await service.reorderRules(user, "r-20", 2);

      expect(result).toBeDefined();
    });
  });
});
