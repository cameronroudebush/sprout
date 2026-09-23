import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { Configuration } from "@backend/config/core.js";
import { WeeklyEmailContent } from "@backend/email/model/weekly-content.js";
import { TestEntities } from "@backend/test/entities.js";

describe("WeeklyEmailContent", () => {
  const user = TestEntities.user;

  it("should format weekly update context fields properly", () => {
    const tx = TestEntities.transaction;
    tx.amount = -50;
    tx.posted = new Date();
    tx.account = TestEntities.account;
    tx.description = "Very long transaction description that exceeds the max limit";
    tx.category = { name: "Food" } as any;

    Configuration.server.email.maxDescriptionLength = 10;

    const content = new WeeklyEmailContent(user, 10000, 200, 1500, 1, [tx]);

    expect(content.user).toBe(user.username);
    expect(content.totalNetWorthText).toBe("$10,000.00");
    expect(content.transactions).toHaveLength(1);
    expect(content.transactions[0]!.amountText).toBe("-$50.00");
    expect(content.transactions[0]!.description).toBe("Very long ...");
    expect(content.transactions[0]!.category).toBe("Food");
  });

  it("should handle transactions without description or category", () => {
    const tx = { ...TestEntities.transaction, description: undefined, category: undefined, amount: 100, posted: undefined };
    const content = new WeeklyEmailContent(user, 5000, 100, 0, 1, [tx as any]);
    expect(content.transactions[0]!.description).toBe("");
    expect(content.transactions[0]!.category).toBe("");
  });

  it("should ignore negative transactions posted outside the past week", () => {
    const oldDate = new Date();
    oldDate.setDate(oldDate.getDate() - 30);
    const tx = {
      ...TestEntities.transaction,
      amount: -25,
      posted: oldDate,
      description: "Old expense",
      category: undefined,
      account: TestEntities.account,
    };

    const content = new WeeklyEmailContent(user, 5000, 100, 0, 1, [tx as any]);

    expect(content.dailySpendingBars.every((bar) => bar.amount === 0)).toBe(true);
  });
});
