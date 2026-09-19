import { setupTests } from "@backend/test/helpers";
setupTests();

import { TestEntities } from "@backend/test/entities";
import { Transaction } from "@backend/transaction/model/transaction.model";

describe("Transaction model", () => {
  it("should create instance properly", () => {
    const account = TestEntities.account;
    const date = new Date();
    const tx = new Transaction(10.5, date, "Starbucks", undefined, false, account);

    expect(tx.description).toBe("Starbucks");
    expect(tx.amount).toBe(10.5);
    expect(tx.account).toBe(account);
  });
});
