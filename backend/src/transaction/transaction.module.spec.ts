import { setupTests } from "@backend/test/helpers";
setupTests();

import { TransactionModule } from "@backend/transaction/transaction.module";

describe("TransactionModule", () => {
  it("should define TransactionModule class", () => {
    expect(TransactionModule).toBeDefined();
  });
});
