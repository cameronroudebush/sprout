import { setupTests } from "@backend/test/helpers";
setupTests();

import { TransactionExtraData } from "@backend/transaction/model/transaction.extra.model";

describe("TransactionExtraData model", () => {
  it("should create instance properly", () => {
    const extra = new TransactionExtraData();
    extra["merchantName"] = "Supermarket";

    expect(extra["merchantName"]).toBe("Supermarket");
  });
});
