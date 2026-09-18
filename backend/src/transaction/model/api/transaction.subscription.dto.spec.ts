import { setupTests } from "@backend/test/helpers";
setupTests();

import { TestEntities } from "@backend/test/entities";
import { BillingPeriod, TransactionSubscription } from "@backend/transaction/model/api/transaction.subscription.dto";

describe("TransactionSubscription DTO", () => {
  it("should create instance with constructor parameters and classifyPeriod", () => {
    const account = TestEntities.account;
    const transaction = TestEntities.transaction;
    const firstPosted = new Date();

    const dto = new TransactionSubscription("Netflix", 15.99, 3, BillingPeriod.MONTHLY, firstPosted, account, transaction);

    expect(dto.description).toBe("Netflix");
    expect(dto.amount).toBe(15.99);
    expect(dto.count).toBe(3);
    expect(dto.period).toBe(BillingPeriod.MONTHLY);
    expect(dto.startDate).toBe(firstPosted);
    expect(dto.account).toBe(account);
    expect(dto.transaction).toBe(transaction);

    expect(TransactionSubscription.classifyPeriod(7)).toBe(BillingPeriod.WEEKLY);
    expect(TransactionSubscription.classifyPeriod(14)).toBe(BillingPeriod.BI_WEEKLY);
    expect(TransactionSubscription.classifyPeriod(30)).toBe(BillingPeriod.MONTHLY);
    expect(TransactionSubscription.classifyPeriod(90)).toBe(BillingPeriod.QUARTERLY);
    expect(TransactionSubscription.classifyPeriod(180)).toBe(BillingPeriod.SEMI_ANNUALLY);
    expect(TransactionSubscription.classifyPeriod(365)).toBe(BillingPeriod.YEARLY);
    expect(TransactionSubscription.classifyPeriod(5)).toBe(BillingPeriod.UNKNOWN);
  });
});
