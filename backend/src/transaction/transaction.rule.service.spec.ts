import { setupTests } from "@backend/test/helpers";
setupTests();

import { TestEntities } from "@backend/test/entities";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionRule } from "@backend/transaction/model/transaction.rule.model";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { IsNull } from "typeorm";

describe("TransactionRuleService", () => {
  let service: TransactionRuleService;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.clearAllMocks();
    service = new TransactionRuleService();
  });

  describe("applyRulesToTransactions", () => {
    it("should construct query options without category key when onlyApplyToEmpty is false", async () => {
      vi.spyOn(TransactionRule, "find").mockResolvedValue([]);
      const findSpy = vi.spyOn(Transaction, "find").mockResolvedValue([]);

      await service.applyRulesToTransactions(user, undefined, false);

      expect(findSpy).toHaveBeenCalledWith({
        where: {
          account: { user: { id: user.id } },
        },
      });
      const passedWhere = findSpy.mock.calls[0]![0]?.where as Record<string, any>;
      expect(Object.prototype.hasOwnProperty.call(passedWhere, "category")).toBe(false);
    });

    it("should construct query options with category: IsNull() when onlyApplyToEmpty is true", async () => {
      vi.spyOn(TransactionRule, "find").mockResolvedValue([]);
      const findSpy = vi.spyOn(Transaction, "find").mockResolvedValue([]);

      await service.applyRulesToTransactions(user, undefined, true);

      expect(findSpy).toHaveBeenCalledWith({
        where: {
          account: { user: { id: user.id } },
          category: IsNull(),
        },
      });
    });

    it("should include account ID in query options when account parameter is provided", async () => {
      const mockAccount = TestEntities.account;
      vi.spyOn(TransactionRule, "find").mockResolvedValue([]);
      const findSpy = vi.spyOn(Transaction, "find").mockResolvedValue([]);

      await service.applyRulesToTransactions(user, mockAccount);

      expect(findSpy).toHaveBeenCalledWith({
        where: {
          account: { user: { id: user.id }, id: mockAccount.id },
        },
      });
    });

    it("should skip disabled rules", async () => {
      const disabledRule = TransactionRule.fromPlain({
        id: "r-disabled",
        user,
        enabled: false,
        matches: 0,
      });
      disabledRule.update = vi.fn().mockResolvedValue(disabledRule);

      vi.spyOn(TransactionRule, "find").mockResolvedValue([disabledRule]);
      vi.spyOn(Transaction, "find").mockResolvedValue([TestEntities.transaction]);

      await service.applyRulesToTransactions(user);

      expect(disabledRule.update).not.toHaveBeenCalled();
    });

    it("should skip rule processing when rule account does not match transaction account, and proceed when it matches", async () => {
      const account1 = { id: "acc-1" } as any;
      const account2 = { id: "acc-2" } as any;

      const rule = TransactionRule.fromPlain({
        id: "r-acc",
        user,
        enabled: true,
        account: account1,
        type: "description",
        strict: true,
        value: "Match",
        matches: 0,
        category: TestEntities.category,
      });
      rule.update = vi.fn().mockResolvedValue(rule);

      // Transaction 1: Different account (Triggers line 68 continue)
      const txDiffAccount = TestEntities.transaction;
      txDiffAccount.id = "tx-1";
      txDiffAccount.account = account2;
      txDiffAccount.description = "Match";
      txDiffAccount.update = vi.fn().mockResolvedValue(txDiffAccount);

      // Transaction 2: Same account (Passes line 68 check)
      const txSameAccount = TestEntities.transaction;
      txSameAccount.id = "tx-2";
      txSameAccount.account = account1;
      txSameAccount.description = "Match";
      txSameAccount.update = vi.fn().mockResolvedValue(txSameAccount);

      vi.spyOn(TransactionRule, "find").mockResolvedValue([rule]);
      vi.spyOn(Transaction, "find").mockResolvedValue([txDiffAccount, txSameAccount]);

      await service.applyRulesToTransactions(user);

      expect(txDiffAccount.update).not.toHaveBeenCalled();
      expect(txSameAccount.update).toHaveBeenCalled();
      expect(rule.matches).toBe(1);
    });

    it("should evaluate amount matching rule and update matching transaction", async () => {
      const amountRule = TransactionRule.fromPlain({
        id: "r-amount",
        user,
        enabled: true,
        type: "amount",
        value: "42.50",
        matches: 0,
        category: TestEntities.category,
      });
      amountRule.update = vi.fn().mockResolvedValue(amountRule);

      const txMatch = TestEntities.transaction;
      txMatch.id = "tx-match";
      txMatch.amount = 42.5;
      txMatch.update = vi.fn().mockResolvedValue(txMatch);

      const txNonMatch = TestEntities.transaction;
      txNonMatch.id = "tx-non-match";
      txNonMatch.amount = 10.0;
      txNonMatch.update = vi.fn().mockResolvedValue(txNonMatch);

      vi.spyOn(TransactionRule, "find").mockResolvedValue([amountRule]);
      vi.spyOn(Transaction, "find").mockResolvedValue([txMatch, txNonMatch]);

      await service.applyRulesToTransactions(user);

      expect(txMatch.category).toEqual(TestEntities.category);
      expect(txMatch.update).toHaveBeenCalled();
      expect(txNonMatch.update).not.toHaveBeenCalled();
      expect(amountRule.matches).toBe(1);
    });

    it("should handle non-matching rule conditions and manually edited transactions without force flag", async () => {
      const strictRule = TransactionRule.fromPlain({
        id: "r-strict",
        user,
        enabled: true,
        type: "description",
        strict: true,
        value: "Target",
        matches: 0,
      });
      strictRule.update = vi.fn().mockResolvedValue(strictRule);

      const substringRule = TransactionRule.fromPlain({
        id: "r-sub",
        user,
        enabled: true,
        type: "description",
        strict: false,
        value: "target | goal",
        matches: 0,
      });
      substringRule.update = vi.fn().mockResolvedValue(substringRule);

      const txNonMatchStrict = TestEntities.transaction;
      txNonMatchStrict.id = "tx-1";
      txNonMatchStrict.description = "Other Description";
      txNonMatchStrict.update = vi.fn().mockResolvedValue(txNonMatchStrict);

      const txNonMatchSubstring = TestEntities.transaction;
      txNonMatchSubstring.id = "tx-2";
      txNonMatchSubstring.description = "Completely Unrelated";
      txNonMatchSubstring.update = vi.fn().mockResolvedValue(txNonMatchSubstring);

      const txManuallyEdited = TestEntities.transaction;
      txManuallyEdited.id = "tx-3";
      txManuallyEdited.description = "Target";
      txManuallyEdited.manuallyEdited = true;
      txManuallyEdited.update = vi.fn().mockResolvedValue(txManuallyEdited);

      vi.spyOn(TransactionRule, "find").mockResolvedValue([strictRule, substringRule]);
      vi.spyOn(Transaction, "find").mockResolvedValue([txNonMatchStrict, txNonMatchSubstring, txManuallyEdited]);

      await service.applyRulesToTransactions(user, undefined, false, false);

      expect(txNonMatchStrict.update).not.toHaveBeenCalled();
      expect(txNonMatchSubstring.update).not.toHaveBeenCalled();
      expect(txManuallyEdited.update).not.toHaveBeenCalled();
    });

    it("should overwrite manually edited transactions when force is true", async () => {
      const rule = TransactionRule.fromPlain({
        id: "r-force",
        user,
        enabled: true,
        type: "description",
        strict: true,
        value: "Target",
        matches: 0,
        category: TestEntities.category,
      });
      rule.update = vi.fn().mockResolvedValue(rule);

      const txManuallyEdited = TestEntities.transaction;
      txManuallyEdited.id = "tx-edited";
      txManuallyEdited.description = "Target";
      txManuallyEdited.manuallyEdited = true;
      txManuallyEdited.update = vi.fn().mockResolvedValue(txManuallyEdited);

      vi.spyOn(TransactionRule, "find").mockResolvedValue([rule]);
      vi.spyOn(Transaction, "find").mockResolvedValue([txManuallyEdited]);

      await service.applyRulesToTransactions(user, undefined, false, true);

      expect(txManuallyEdited.manuallyEdited).toBe(false);
      expect(txManuallyEdited.category).toEqual(TestEntities.category);
      expect(txManuallyEdited.update).toHaveBeenCalled();
    });

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
      tx.update = vi.fn().mockResolvedValue(tx);
      rule.update = vi.fn().mockResolvedValue(rule);

      vi.spyOn(TransactionRule, "find").mockResolvedValue([rule]);
      vi.spyOn(Transaction, "find").mockResolvedValue([tx]);

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
      tx1.update = vi.fn().mockResolvedValue(tx1);

      const tx2 = TestEntities.transaction;
      tx2.id = "tx-2";
      tx2.description = "No Match";
      tx2.amount = 25.5;
      tx2.update = vi.fn().mockResolvedValue(tx2);

      const txUnmatched = TestEntities.transaction;
      txUnmatched.id = "tx-3";
      txUnmatched.description = "Unmatched";
      txUnmatched.amount = 100;
      txUnmatched.category = TestEntities.category;
      txUnmatched.update = vi.fn().mockResolvedValue(txUnmatched);

      strictRule.update = vi.fn().mockResolvedValue(strictRule);
      amountRule.update = vi.fn().mockResolvedValue(amountRule);

      vi.spyOn(TransactionRule, "find").mockResolvedValue([strictRule, amountRule]);
      vi.spyOn(Transaction, "find").mockResolvedValue([tx1, tx2, txUnmatched]);

      await service.applyRulesToTransactions(user, undefined, false, false, true);

      expect(txUnmatched.category).toBeUndefined();
      expect(txUnmatched.update).toHaveBeenCalled();
    });

    it("should leave unknown rule types unmatched", async () => {
      const rule = TransactionRule.fromPlain({ id: "unknown", user, enabled: true, type: "unknown" as any, value: "value", matches: 0 });
      rule.update = vi.fn().mockResolvedValue(rule);
      const tx = TestEntities.transaction;
      tx.id = "unknown-tx";
      tx.update = vi.fn().mockResolvedValue(tx);
      vi.spyOn(TransactionRule, "find").mockResolvedValue([rule]);
      vi.spyOn(Transaction, "find").mockResolvedValue([tx]);

      await service.applyRulesToTransactions(user);

      expect(tx.update).not.toHaveBeenCalled();
      expect(rule.update).toHaveBeenCalled();
    });
  });

  describe("reorderRules", () => {
    it("should slide overlapping rules when expectedIndex matches targetPosition", async () => {
      // Target position is 2.
      // For i = 0 (rule2): order is 2 -> expectedIndex = 3 -> targetPosition (2) + i (0) + 1 = 3 (Matches!)
      const rule2 = TransactionRule.fromPlain({ id: "r-2", order: 2, user });
      rule2.update = vi.fn().mockResolvedValue(rule2);

      // For i = 1 (rule3): order MUST be 3 -> expectedIndex = 4 -> targetPosition (2) + i (1) + 1 = 4 (Matches!)
      const rule3 = TransactionRule.fromPlain({ id: "r-3", order: 3, user });
      rule3.update = vi.fn().mockResolvedValue(rule3);
      const ruleMismatch = TransactionRule.fromPlain({ id: "r-mismatch", order: 99, user });
      ruleMismatch.update = vi.fn().mockResolvedValue(ruleMismatch);

      const rule1 = TransactionRule.fromPlain({ id: "r-1", order: 1, user });

      vi.spyOn(TransactionRule, "find").mockImplementation(async (opts: any) => {
        if (opts?.where?.order) {
           return [rule2, rule3, ruleMismatch];
        }
        return [rule1, rule2, rule3];
      });

      const result = await service.reorderRules(user, "r-new", 2);

      // Line 109 executes for both sliding rules
      expect(rule2.order).toBe(3);
      expect(rule2.update).toHaveBeenCalled();
      expect(rule3.order).toBe(4);
      expect(rule3.update).toHaveBeenCalled();
      expect(result).toBeDefined();
    });

    it("should do nothing to sliding rules if matchingPriority is -1", async () => {
      const rule1 = TransactionRule.fromPlain({ id: "r-10", order: 1, user });
      rule1.update = vi.fn().mockResolvedValue(rule1);

      vi.spyOn(TransactionRule, "find").mockResolvedValue([rule1]);

      const result = await service.reorderRules(user, "r-10", 5);

      expect(rule1.update).not.toHaveBeenCalled();
      expect(result).toBeDefined();
    });
  });
});
