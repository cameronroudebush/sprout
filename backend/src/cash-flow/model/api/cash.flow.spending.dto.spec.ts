import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { CashFlowSpending } from "@backend/cash-flow/model/api/cash.flow.spending.dto.js";

describe("CashFlowSpending DTO", () => {
  it("should instantiate CashFlowSpending DTO", () => {
    const dto = new CashFlowSpending([], ["Groceries"]);
    expect(dto.data).toEqual([]);
    expect(dto.topCategoryNames).toEqual(["Groceries"]);
  });
});
