import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountSubType } from "@backend/account/model/account.sub.type";
import { AccountType } from "@backend/account/model/account.type";
import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { Institution } from "@backend/institution/model/institution.model";
import { ProviderType } from "@backend/providers/base/provider.type";
import { User } from "@backend/user/model/user.model";

describe("Account Model", () => {
  let mockUser: User;
  let mockInstitution: Institution;

  beforeEach(() => {
    mockUser = { id: "user-123", config: { currency: "USD" } } as unknown as User;
    mockInstitution = { id: "inst-1", name: "Bank" } as unknown as Institution;

    // Spy on ActiveRecord methods to not hit a real database
    jest.spyOn(Account, "find").mockResolvedValue([]);
    jest.spyOn(CurrencyHelper, "convertList").mockImplementation((arr) => arr);

    // We mock AccountHistory.fromPlain to avoid hitting the actual method
    jest.spyOn(AccountHistory, "fromPlain").mockImplementation((obj: any) => obj as any);
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe("Constructor", () => {
    it("should instantiate an Account object correctly", () => {
      const account = new Account("Checking", ProviderType.plaid, mockUser, mockInstitution, 1000, 900, AccountType.depository, "USD", AccountSubType.checking);

      expect(account.name).toBe("Checking");
      expect(account.provider).toBe(ProviderType.plaid);
      expect(account.user).toEqual(mockUser);
      expect(account.institution).toEqual(mockInstitution);
      expect(account.balance).toBe(1000);
      expect(account.availableBalance).toBe(900);
      expect(account.type).toBe(AccountType.depository);
      expect(account.currency).toBe("USD");
      expect(account.subType).toBe(AccountSubType.checking);
    });
  });

  describe("getForUser", () => {
    it("should call Account.find with the correct user ID", async () => {
      const mockAccounts = [new Account("Checking", ProviderType.plaid, mockUser, mockInstitution, 1000, 900, AccountType.depository, "USD")];
      (Account.find as jest.Mock).mockResolvedValue(mockAccounts);

      const result = await Account.getForUser(mockUser);

      expect(Account.find).toHaveBeenCalledWith({ where: { user: { id: mockUser.id } } });
      expect(result).toEqual(mockAccounts);
    });
  });

  describe("toAccountHistory", () => {
    it("should return an AccountHistory representation of the account with the provided date", () => {
      const account = new Account("Checking", ProviderType.plaid, mockUser, mockInstitution, 1000, 900, AccountType.depository, "USD");
      const date = new Date("2023-01-01T00:00:00.000Z");

      const result = account.toAccountHistory(date);

      expect(AccountHistory.fromPlain).toHaveBeenCalledWith({
        balance: 1000,
        account: account,
        availableBalance: 900,
        time: date,
      });
      expect(result).toEqual({
        balance: 1000,
        account: account,
        availableBalance: 900,
        time: date,
      });
    });

    it("should return an AccountHistory representation of the account with the current date if none is provided", () => {
      const account = new Account("Checking", ProviderType.plaid, mockUser, mockInstitution, 1000, 900, AccountType.depository, "USD");

      const before = new Date();
      const result = account.toAccountHistory() as any;
      const after = new Date();

      expect(AccountHistory.fromPlain).toHaveBeenCalled();
      expect(result.balance).toBe(1000);
      expect(result.availableBalance).toBe(900);
      expect(result.account).toEqual(account);
      expect(result.time.getTime()).toBeGreaterThanOrEqual(before.getTime());
      expect(result.time.getTime()).toBeLessThanOrEqual(after.getTime());
    });
  });

  describe("isNegativeNetWorth", () => {
    it("should return true if the account is a credit account", () => {
      const account = new Account("Credit", ProviderType.plaid, mockUser, mockInstitution, 1000, 900, AccountType.credit, "USD");
      expect(account.isNegativeNetWorth).toBe(true);
    });

    it("should return true if the account is a loan account", () => {
      const account = new Account("Loan", ProviderType.plaid, mockUser, mockInstitution, 1000, 900, AccountType.loan, "USD");
      expect(account.isNegativeNetWorth).toBe(true);
    });

    it("should return false if the account is neither a credit nor loan account", () => {
      const account = new Account("Checking", ProviderType.plaid, mockUser, mockInstitution, 1000, 900, AccountType.depository, "USD");
      expect(account.isNegativeNetWorth).toBe(false);
    });
  });

  describe("validateSubType", () => {
    it("should not throw an error for a valid subType", () => {
      expect(() => Account.validateSubType(AccountSubType.checking)).not.toThrow();
    });

    it("should throw an error for an invalid subType", () => {
      expect(() => Account.validateSubType("invalid_subtype")).toThrow("Invalid subType provided: invalid_subtype");
    });
  });

  describe("convertListToTargetCurrency", () => {
    it("should call CurrencyHelper.convertList with correct parameters", () => {
      const accounts = [new Account("Checking", ProviderType.plaid, mockUser, mockInstitution, 1000, 900, AccountType.depository, "USD")];

      const result = Account.convertListToTargetCurrency(accounts, mockUser);

      expect(CurrencyHelper.convertList).toHaveBeenCalledWith(accounts, "balance", "currency", mockUser);
      expect(result).toEqual(accounts);
    });
  });
});
