import { setupTests } from "@backend/test/helpers";
setupTests();

import { WeeklyEmailContent } from "@backend/email/model/weekly-content";
import { TestEntities } from "@backend/test/entities";

describe("WeeklyEmailContent", () => {
  const user = TestEntities.user;

  it("should format weekly update context fields properly", () => {
    const tx = TestEntities.transaction;
    tx.amount = -50;
    tx.account = TestEntities.account;

    const content = new WeeklyEmailContent(user, 10000, 200, 1500, 1, [tx]);

    expect(content.user).toBe(user.username);
    expect(content.totalNetWorthText).toBe("$10,000.00");
    expect(content.transactions).toHaveLength(1);
    expect(content.transactions[0]!.amountText).toBe("-$50.00");
  });
});
