import { setupTests } from "@backend/test/helpers";
setupTests();

import { CashFlowModule } from "@backend/cash-flow/cash.flow.module";

describe("CashFlowModule", () => {
  it("should define module class", () => {
    expect(CashFlowModule).toBeDefined();
  });
});
