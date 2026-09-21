import { setupTests } from "@backend/test/helpers";
setupTests();

import { TotalTransactions } from "@backend/transaction/model/api/total.transaction.dto";

describe("TotalTransactions DTO", () => {
  it("should create instance with constructor parameters", () => {
    const dto = new TotalTransactions({ acc1: 100 }, 100);

    expect(dto.accounts).toEqual({ acc1: 100 });
    expect(dto.total).toBe(100);
  });
});
