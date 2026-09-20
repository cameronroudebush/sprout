import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { CurrencyHelper } from "@backend/core/model/utility/currency.helper.js";
import { TestEntities } from "@backend/test/entities.js";
import { Transaction } from "@backend/transaction/model/transaction.model.js";

describe("Transaction model", () => {
  it("should create instance properly", () => {
    const account = TestEntities.account;
    const date = new Date();
    const tx = new Transaction(10.5, date, "Starbucks", undefined, false, account);

    expect(tx.description).toBe("Starbucks");
    expect(tx.amount).toBe(10.5);
    expect(tx.account).toBe(account);
  });

  it("should convert list to target currency", () => {
    const user = TestEntities.user;
    const account = TestEntities.account;
    const tx = new Transaction(10.5, new Date(), "Starbucks", undefined, false, account);

    const spy = vi.spyOn(CurrencyHelper, "convertList").mockImplementation(() => []);
    const res = Transaction.convertListToTargetCurrency([tx], user);

    expect(spy).toHaveBeenCalledWith([tx], "amount", "account.currency", user);
    expect(res).toEqual([tx]);
  });
});
