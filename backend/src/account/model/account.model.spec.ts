import { setupTests } from "@backend/test/helpers";
setupTests();

import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountSubType } from "@backend/account/model/account.sub.type";
import { AccountType } from "@backend/account/model/account.type";
import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { Institution } from "@backend/institution/model/institution.model";
import { ProviderType } from "@backend/providers/base/provider.type";
import { User } from "@backend/user/model/user.model";

describe("Account", () => {
  let mockUser: User;
  let mockInstitution: Institution;

  beforeEach(() => {
    jest.clearAllMocks();
    mockUser = { id: "user-123" } as User;
    mockInstitution = { id: "inst-123" } as Institution;
  });

  describe("Constructor and Properties", () => {
    it("should correctly instantiate an Account object with all passed fields", () => {
      const account = new Account(
        "Checking Account",
        ProviderType.plaid,
        mockUser,
        mockInstitution,
        1500.5,
        1400.0,
        AccountType.depository,
        "USD",
        AccountSubType.checking,
      );

      expect(account.name).toBe("Checking Account");
      expect(account.provider).toBe(ProviderType.plaid);
      expect(account.user).toBe(mockUser);
      expect(account.institution).toBe(mockInstitution);
      expect(account.balance).toBe(1500.5);
      expect(account.availableBalance).toBe(1400.0);
      expect(account.type).toBe(AccountType.depository);
      expect(account.currency).toBe("USD");
      expect(account.subType).toBe(AccountSubType.checking);
    });

    it("should instantiate an Account with undefined optional fields", () => {
      const account = new Account("Credit Card", ProviderType.simpleFin, mockUser, mockInstitution, -500, -500, AccountType.credit, "EUR");

      expect(account.subType).toBeUndefined();
      expect(account.interestRate).toBeUndefined();
      expect(account.extra).toBeUndefined();
    });
  });

  describe("getForUser", () => {
    it("should invoke the static DatabaseBase find method with the correct query structure", async () => {
      const findSpy = jest.spyOn(Account, "find").mockResolvedValue([]);

      await Account.getForUser(mockUser);

      expect(findSpy).toHaveBeenCalledWith({
        where: { user: { id: "user-123" } },
      });
    });
  });

  describe("toAccountHistory", () => {
    it("should generate an AccountHistory instance from the account metrics using the provided date", () => {
      const account = new Account("Savings", ProviderType.plaid, mockUser, mockInstitution, 5000, 5000, AccountType.depository, "USD");
      const testDate = new Date("2026-06-02T00:00:00.000Z");
      const fromPlainSpy = jest.spyOn(AccountHistory, "fromPlain").mockReturnValue({} as AccountHistory);

      account.toAccountHistory(testDate);

      expect(fromPlainSpy).toHaveBeenCalledWith({
        balance: 5000,
        account: account,
        availableBalance: 5000,
        time: testDate,
      });
    });

    it("should generate an AccountHistory instance using a default current date if none is supplied", () => {
      const account = new Account("Savings", ProviderType.plaid, mockUser, mockInstitution, 5000, 5000, AccountType.depository, "USD");
      const fromPlainSpy = jest.spyOn(AccountHistory, "fromPlain").mockReturnValue({} as AccountHistory);

      account.toAccountHistory();

      expect(fromPlainSpy).toHaveBeenCalledWith({
        balance: 5000,
        account: account,
        availableBalance: 5000,
        time: expect.any(Date),
      });
    });
  });

  describe("isNegativeNetWorth", () => {
    it("should evaluate to true if the account type is credit", () => {
      const account = new Account("Card", ProviderType.plaid, mockUser, mockInstitution, 0, 0, AccountType.credit, "USD");
      expect(account.isNegativeNetWorth).toBe(true);
    });

    it("should evaluate to true if the account type is loan", () => {
      const account = new Account("Student Loan", ProviderType.plaid, mockUser, mockInstitution, 0, 0, AccountType.loan, "USD");
      expect(account.isNegativeNetWorth).toBe(true);
    });

    it("should evaluate to false if the account type is depository", () => {
      const account = new Account("Checking", ProviderType.plaid, mockUser, mockInstitution, 0, 0, AccountType.depository, "USD");
      expect(account.isNegativeNetWorth).toBe(false);
    });
  });

  describe("validateSubType", () => {
    it("should pass without error when an established valid AccountSubType is passed", () => {
      expect(() => Account.validateSubType(AccountSubType.checking)).not.toThrow();
    });

    it("should throw an error specifying the invalid subType when an unknown string is passed", () => {
      expect(() => Account.validateSubType("invalid-sub-type")).toThrow(new Error("Invalid subType provided: invalid-sub-type"));
    });
  });

  describe("convertListToTargetCurrency", () => {
    it("should trigger CurrencyHelper conversion utility and pass back the modified array instance", () => {
      const account1 = new Account("A1", ProviderType.simpleFin, mockUser, mockInstitution, 10, 10, AccountType.depository, "EUR");
      const account2 = new Account("A2", ProviderType.simpleFin, mockUser, mockInstitution, 20, 20, AccountType.depository, "GBP");
      const list = [account1, account2];
      const convertListSpy = jest.spyOn(CurrencyHelper, "convertList").mockImplementation(() => {});

      const result = Account.convertListToTargetCurrency(list, mockUser);

      expect(convertListSpy).toHaveBeenCalledWith(list, "balance", "currency", mockUser);
      expect(result).toBe(list);
    });
  });
});
