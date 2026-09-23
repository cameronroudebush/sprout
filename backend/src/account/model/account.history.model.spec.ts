import { setupTests } from "@backend/test/helpers";
setupTests();

import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { User } from "@backend/user/model/user.model";

describe("AccountHistory", () => {
  let mockAccount: Account;
  let mockUser: User;

  beforeEach(() => {
    vi.clearAllMocks();
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

  describe("fromAccount", () => {
    it("should instantiate an AccountHistory object using the default current date when date parameter is omitted", () => {
      const beforeCall = new Date();
      const history = AccountHistory.fromAccount(mockAccount);
      const afterCall = new Date();

      expect(history.account).toEqual(mockAccount);
      expect(history.balance).toBe(2500);
      expect(history.availableBalance).toBe(2400);
      expect(history.time.getTime()).toBeGreaterThanOrEqual(beforeCall.getTime());
      expect(history.time.getTime()).toBeLessThanOrEqual(afterCall.getTime());
    });

    it("should instantiate an AccountHistory object using the specified custom date", () => {
      const customDate = new Date("2026-01-01T00:00:00.000Z");
      const history = AccountHistory.fromAccount(mockAccount, customDate);

      expect(history.account).toEqual(mockAccount);
      expect(history.balance).toBe(2500);
      expect(history.availableBalance).toBe(2400);
      expect(history.time).toEqual(customDate);
    });
  });

  describe("insertForAccount", () => {
    it("should insert history item timed one day prior to current execution date", async () => {
      const expectedDate = new Date("2026-06-01T12:00:00.000Z");
      vi.useFakeTimers().setSystemTime(new Date("2026-06-02T12:00:00.000Z"));

      const insertSpy = vi.fn().mockResolvedValue(undefined);
      vi.spyOn(AccountHistory, "fromPlain").mockReturnValue({ insert: insertSpy } as any);

      await AccountHistory.insertForAccount(mockAccount);

      expect(AccountHistory.fromPlain).toHaveBeenCalledWith({
        account: mockAccount,
        balance: 2500,
        availableBalance: 2400,
        time: expectedDate,
      });
      expect(insertSpy).toHaveBeenCalled();

      vi.useRealTimers();
    });
  });

  describe("insertForNewAccount", () => {
    it("should create and insert an instance with balances forced to zero when includeBalances is false", async () => {
      const expectedDate = new Date("2026-06-01T12:00:00.000Z");
      vi.useFakeTimers().setSystemTime(new Date("2026-06-02T12:00:00.000Z"));

      const insertSpy = vi.spyOn(AccountHistory.prototype, "insert").mockResolvedValue({} as any);

      await AccountHistory.insertForNewAccount(mockAccount, false);

      expect(insertSpy).toHaveBeenCalled();

      const instanceCalledOn = (await insertSpy.mock.instances[0])!;
      expect(instanceCalledOn.account).toBe(mockAccount);
      expect(instanceCalledOn.time).toEqual(expectedDate);
      expect(instanceCalledOn.balance).toBe(0);
      expect(instanceCalledOn.availableBalance).toBe(0);

      vi.useRealTimers();
    });

    it("should create and insert an instance with balances forced to zero when includeBalances is omitted", async () => {
      vi.useFakeTimers().setSystemTime(new Date("2026-06-02T12:00:00.000Z"));
      const insertSpy = vi.spyOn(AccountHistory.prototype, "insert").mockResolvedValue({} as any);

      await AccountHistory.insertForNewAccount(mockAccount);

      const instanceCalledOn = (await insertSpy.mock.instances[0])!;
      expect(instanceCalledOn.balance).toBe(0);
      expect(instanceCalledOn.availableBalance).toBe(0);

      vi.useRealTimers();
    });

    it("should create and insert an instance reflecting the current account balances when includeBalances is true", async () => {
      vi.useFakeTimers().setSystemTime(new Date("2026-06-02T12:00:00.000Z"));
      const insertSpy = vi.spyOn(AccountHistory.prototype, "insert").mockResolvedValue({} as any);

      await AccountHistory.insertForNewAccount(mockAccount, true);

      const instanceCalledOn = (await insertSpy.mock.instances[0])!;
      expect(instanceCalledOn.balance).toBe(2500);
      expect(instanceCalledOn.availableBalance).toBe(2400);

      vi.useRealTimers();
    });
  });

  describe("convertListToTargetCurrency", () => {
    it("should trigger CurrencyHelper list conversion with deep property path and hand back the same array reference", () => {
      const history1 = new AccountHistory(mockAccount, new Date(), 100, 100);
      const history2 = new AccountHistory(mockAccount, new Date(), 200, 200);
      const list = [history1, history2];
      const convertListSpy = vi.spyOn(CurrencyHelper, "convertList").mockImplementation(() => {});

      const result = AccountHistory.convertListToTargetCurrency(list, mockUser);

      expect(convertListSpy).toHaveBeenCalledWith(list, "balance", "account.currency", mockUser);
      expect(result).toBe(list);
    });
  });
});
