import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { User } from "@backend/user/model/user.model";

describe("AccountHistory Model", () => {
  let mockAccount: Account;
  let mockUser: User;

  beforeEach(() => {
    mockAccount = {
      id: "acc-1",
      balance: 1000,
      availableBalance: 900,
      currency: "USD",
    } as unknown as Account;

    mockUser = {
      id: "user-1",
    } as unknown as User;

    // Spy on DatabaseBase insert to mock it properly
    jest.spyOn(AccountHistory.prototype, "insert").mockImplementation(async function(this: AccountHistory) {
      return this;
    });

    jest.spyOn(CurrencyHelper, "convertList").mockImplementation((arr) => arr);
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe("Constructor", () => {
    it("should instantiate an AccountHistory object correctly", () => {
      const time = new Date();
      const history = new AccountHistory(mockAccount, time, 500, 450);

      expect(history.account).toEqual(mockAccount);
      expect(history.time).toEqual(time);
      expect(history.balance).toBe(500);
      expect(history.availableBalance).toBe(450);
    });
  });

  describe("insertForNewAccount", () => {
    it("should insert a history object with account balances when includeBalances is true", async () => {
      const history = await AccountHistory.insertForNewAccount(mockAccount, true);

      expect(history.account).toEqual(mockAccount);
      expect(history.balance).toBe(mockAccount.balance);
      expect(history.availableBalance).toBe(mockAccount.availableBalance);
      // Ensure time is approximately yesterday
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      expect(history.time.getDate()).toBe(yesterday.getDate());
    });

    it("should insert a history object with 0 balances when includeBalances is false", async () => {
      const history = await AccountHistory.insertForNewAccount(mockAccount, false);

      expect(history.account).toEqual(mockAccount);
      expect(history.balance).toBe(0);
      expect(history.availableBalance).toBe(0);
    });

    it("should default includeBalances to false if not provided", async () => {
      const history = await AccountHistory.insertForNewAccount(mockAccount);

      expect(history.account).toEqual(mockAccount);
      expect(history.balance).toBe(0);
      expect(history.availableBalance).toBe(0);
    });
  });

  describe("convertListToTargetCurrency", () => {
    it("should call CurrencyHelper.convertList with correct parameters", () => {
      const histories = [
        new AccountHistory(mockAccount, new Date(), 500, 450),
      ];

      const result = AccountHistory.convertListToTargetCurrency(histories, mockUser);

      expect(CurrencyHelper.convertList).toHaveBeenCalledWith(histories, "balance", "account.currency", mockUser);
      expect(result).toEqual(histories);
    });
  });
});
