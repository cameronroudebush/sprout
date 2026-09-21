import { setupTests } from "@backend/test/helpers";
setupTests();

import { TestEntities } from "@backend/test/entities";
import { TransactionRule } from "@backend/transaction/model/transaction.rule.model";
import { TransactionRuleType } from "@backend/transaction/model/transaction.rule.type";

describe("TransactionRule model", () => {
  it("should create instance properly", () => {
    const user = TestEntities.user;
    const rule = new TransactionRule(user, TransactionRuleType.description, "Starbucks");

    expect(rule.user).toBe(user);
    expect(rule.type).toBe(TransactionRuleType.description);
    expect(rule.value).toBe("Starbucks");
  });
});
