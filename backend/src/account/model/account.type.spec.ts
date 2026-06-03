import { AccountType, AccountTypeIsLiability } from "@backend/account/model/account.type";

describe("AccountTypeIsLiability", () => {
  it("should return true if the account type is a loan or credit", () => {
    expect(AccountTypeIsLiability(AccountType.loan)).toBe(true);
    expect(AccountTypeIsLiability(AccountType.credit)).toBe(true);
  });

  it("should return false for non-liability account types", () => {
    // Assuming you have other types like checking, savings, asset, etc.
    expect(AccountTypeIsLiability(AccountType.depository)).toBe(false);
    expect(AccountTypeIsLiability(AccountType.asset)).toBe(false);
  });

  it("should return false for undefined or null values", () => {
    // @ts-ignore - bypassing TS to test runtime robustness if input comes from API
    expect(AccountTypeIsLiability(undefined)).toBe(false);
    // @ts-ignore
    expect(AccountTypeIsLiability(null)).toBe(false);
  });
});
