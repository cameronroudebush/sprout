import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it } from "vitest";

setupTests();

import { AccountEditRequest } from "./edit.request.dto.js";

describe("AccountEditRequest", () => {
  it("should create instance with name and interest rate", () => {
    const dto = new AccountEditRequest();
    dto.name = "Savings";
    dto.interestRate = 4.5;

    expect(dto.name).toBe("Savings");
    expect(dto.interestRate).toBe(4.5);
  });
});
