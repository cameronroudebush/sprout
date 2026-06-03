import { setupTests } from "@backend/test/helpers";
setupTests();

import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { User } from "@backend/user/model/user.model";
import dateFns from "date-fns";

describe("AccountHistory", () => {
  let mockAccount: Account;
  let mockUser: User;

  beforeEach(() => {
    jest.clearAllMocks();
    mockAccount = { balance: 2500, availableBalance: 2400 } as Account;
    mockUser = { id: "user-999" } as User;
  });

  describe("Constructor and Properties", () => {
    it("should correctly instantiate an AccountHistory instance with all fields", () => {
      const testDate = new Date();
      const history = new AccountHistory(mockAccount, testDate, 1000, 900);

      expect(history.account).toBe(mockAccount);
      expect(history.time).toBe(testDate);
      expect(history.balance).toBe(1000);
      expect(history.availableBalance).toBe(900);
    });
  });

  describe("insertForNewAccount", () => {
    it("should create and insert an instance with balances forced to zero when includeBalances is false", async () => {
      const expectedDate = new Date("2026-06-01T12:00:00.000Z");
      jest.useFakeTimers().setSystemTime(new Date("2026-06-02T12:00:00.000Z"));

      const insertSpy = jest.spyOn(AccountHistory.prototype, "insert").mockResolvedValue({} as any);

      await AccountHistory.insertForNewAccount(mockAccount, false);

      expect(dateFns.subDays).toHaveBeenCalledWith(expect.any(Date), 1);
      expect(insertSpy).toHaveBeenCalled();

      const instanceCalledOn = (await insertSpy.mock.instances[0])!;
      expect(instanceCalledOn.account).toBe(mockAccount);
      expect(instanceCalledOn.time).toEqual(expectedDate);
      expect(instanceCalledOn.balance).toBe(0);
      expect(instanceCalledOn.availableBalance).toBe(0);

      jest.useRealTimers();
    });

    it("should create and insert an instance with balances forced to zero when includeBalances is omitted", async () => {
      jest.useFakeTimers().setSystemTime(new Date("2026-06-02T12:00:00.000Z"));
      const insertSpy = jest.spyOn(AccountHistory.prototype, "insert").mockResolvedValue({} as any);

      await AccountHistory.insertForNewAccount(mockAccount);

      const instanceCalledOn = (await insertSpy.mock.instances[0])!;
      expect(instanceCalledOn.balance).toBe(0);
      expect(instanceCalledOn.availableBalance).toBe(0);

      jest.useRealTimers();
    });

    it("should create and insert an instance reflecting the current account balances when includeBalances is true", async () => {
      jest.useFakeTimers().setSystemTime(new Date("2026-06-02T12:00:00.000Z"));
      const insertSpy = jest.spyOn(AccountHistory.prototype, "insert").mockResolvedValue({} as any);

      await AccountHistory.insertForNewAccount(mockAccount, true);

      const instanceCalledOn = (await insertSpy.mock.instances[0])!;
      expect(instanceCalledOn.balance).toBe(2500);
      expect(instanceCalledOn.availableBalance).toBe(2400);

      jest.useRealTimers();
    });
  });

  describe("convertListToTargetCurrency", () => {
    it("should trigger CurrencyHelper list conversion with deep property path and hand back the same array reference", () => {
      const history1 = new AccountHistory(mockAccount, new Date(), 100, 100);
      const history2 = new AccountHistory(mockAccount, new Date(), 200, 200);
      const list = [history1, history2];
      const convertListSpy = jest.spyOn(CurrencyHelper, "convertList").mockImplementation(() => {});

      const result = AccountHistory.convertListToTargetCurrency(list, mockUser);

      expect(convertListSpy).toHaveBeenCalledWith(list, "balance", "account.currency", mockUser);
      expect(result).toBe(list);
    });
  });
});
