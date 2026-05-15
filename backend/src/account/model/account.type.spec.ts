import { AccountType, AccountTypeIsLiability } from "@backend/account/model/account.type";

describe("Account Type Model", () => {
  describe("AccountTypeIsLiability", () => {
    it("should return true for a loan account", () => {
      expect(AccountTypeIsLiability(AccountType.loan)).toBe(true);
    });

    it("should return true for a credit account", () => {
      expect(AccountTypeIsLiability(AccountType.credit)).toBe(true);
    });

    it("should return false for other account types", () => {
      expect(AccountTypeIsLiability(AccountType.depository)).toBe(false);
      expect(AccountTypeIsLiability(AccountType.investment)).toBe(false);
      expect(AccountTypeIsLiability(AccountType.other)).toBe(false);
    });
  });
});
