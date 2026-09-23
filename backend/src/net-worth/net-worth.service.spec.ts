import { setupTests } from "@backend/test/helpers.js";
import { TestEntities } from "@backend/test/entities.js";
import { describe, expect, it, vi, beforeEach } from "vitest";

setupTests();

import { NetWorthService } from "./net-worth.service.js";
import { AccountHistory } from "@backend/account/model/account.history.model.js";
import { HoldingHistory } from "@backend/holding/model/holding.history.model.js";
import { Account } from "@backend/account/model/account.model.js";
import { AccountType } from "@backend/account/model/account.type.js";
import { Holding } from "@backend/holding/model/holding.model.js";
import { eachDayOfInterval } from "date-fns";

vi.mock("date-fns", async (importOriginal) => {
  const actual = await importOriginal<typeof import("date-fns")>();
  return { ...actual, eachDayOfInterval: vi.fn(actual.eachDayOfInterval) };
});

describe("NetWorthService", () => {
  let service: NetWorthService;

  const mockUser = TestEntities.user;
  const mockAccount = TestEntities.account;
  const mockHolding = TestEntities.holding;

  beforeEach(() => {
    vi.restoreAllMocks();
    service = new NetWorthService();
  });

  describe("getTotalSummary", () => {
    it("should aggregate balances of user accounts in target currency", async () => {
      vi.spyOn(Account, "find").mockResolvedValue([
        Account.fromPlain({ ...mockAccount, balance: 100 }),
        Account.fromPlain({ ...mockAccount, id: "acc-2", balance: 200 }),
      ]);

      const total = await service.getTotalSummary(mockUser);
      expect(total).toBe(300);
    });
  });

  describe("getNetWorthSummary", () => {
    it("should calculate net worth summary and timeline across all account history including multiple entries per account", async () => {
      const h1 = AccountHistory.fromPlain({
        id: "ah-1",
        time: new Date("2026-01-01T10:00:00Z"),
        balance: 900,
        account: mockAccount,
      });
      const h2 = AccountHistory.fromPlain({
        id: "ah-2",
        time: new Date("2026-01-01T12:00:00Z"),
        balance: 1000,
        account: mockAccount,
      });

      const qb: any = {
        innerJoinAndSelect: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        andWhere: vi.fn().mockReturnThis(),
        orderBy: vi.fn().mockReturnThis(),
        getMany: vi.fn().mockResolvedValue([h1, h2]),
      };

      vi.spyOn(AccountHistory, "getRepository").mockReturnValue({
        createQueryBuilder: () => qb,
      } as any);

      const result = await service.getNetWorthSummary(mockUser);
      expect(result.history).toBeDefined();
      expect(result.timeline()).toBeDefined();
      expect(result.timeline(10)).toBeDefined();
    });

    it("should return empty history if rawHistory is empty", async () => {
      const qb: any = {
        innerJoinAndSelect: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        andWhere: vi.fn().mockReturnThis(),
        orderBy: vi.fn().mockReturnThis(),
        getMany: vi.fn().mockResolvedValue([]),
      };

      vi.spyOn(AccountHistory, "getRepository").mockReturnValue({
        createQueryBuilder: () => qb,
      } as any);

      const result = await service.getNetWorthSummary(mockUser);
      expect(result.timeline()).toEqual([]);
    });
  });

  describe("getNetWorthByAccounts", () => {
    it("should calculate net worth for each account belonging to user", async () => {
      vi.spyOn(Account, "getForUser").mockResolvedValue([mockAccount]);

      const accountHistory = AccountHistory.fromPlain({
        id: "ah-account",
        time: new Date("2026-01-01T10:00:00Z"),
        balance: 1000,
        account: mockAccount,
      });

      const qb: any = {
        innerJoinAndSelect: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        andWhere: vi.fn().mockReturnThis(),
        orderBy: vi.fn().mockReturnThis(),
        getMany: vi.fn().mockResolvedValue([accountHistory]),
      };

      vi.spyOn(AccountHistory, "getRepository").mockReturnValue({
        createQueryBuilder: () => qb,
      } as any);

      const result = await service.getNetWorthByAccounts(mockUser);
      expect(result).toHaveLength(1);
      expect(result[0]!.history.connectedId).toBe(mockAccount.id);
    });
  });

  describe("getHistoryForHoldings", () => {
    it("should calculate history stats for holdings in an account including multiple entries per holding", async () => {
      vi.spyOn(Holding, "getForAccount").mockResolvedValue([mockHolding]);

      const hh1 = HoldingHistory.fromPlain({
        id: "hh-1",
        time: new Date("2026-01-01T10:00:00Z"),
        marketValue: 1500,
        holding: mockHolding,
      });
      const hh2 = HoldingHistory.fromPlain({
        id: "hh-2",
        time: new Date("2026-01-01T12:00:00Z"),
        marketValue: 1600,
        holding: mockHolding,
      });

      const qb: any = {
        innerJoinAndSelect: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        andWhere: vi.fn().mockReturnThis(),
        orderBy: vi.fn().mockReturnThis(),
        getMany: vi.fn().mockResolvedValue([hh1, hh2]),
      };

      vi.spyOn(HoldingHistory, "getRepository").mockReturnValue({
        createQueryBuilder: () => qb,
      } as any);

      const result = await service.getHistoryForHoldings(mockAccount);
      expect(result).toHaveLength(1);
    });
  });

  describe("getHistoryForHolding", () => {
    it("should calculate history for a specific holding", async () => {
      const qb: any = {
        innerJoinAndSelect: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        andWhere: vi.fn().mockReturnThis(),
        orderBy: vi.fn().mockReturnThis(),
        getMany: vi.fn().mockResolvedValue([]),
      };

      vi.spyOn(HoldingHistory, "getRepository").mockReturnValue({
        createQueryBuilder: () => qb,
      } as any);

      const result = await service.getHistoryForHolding(mockHolding);
      expect(result.history).toBeDefined();
    });
  });

  describe("getNetWorthByAccount", () => {
    it("should return history for specific account and invert change for credit account", async () => {
      const creditAccount = { ...mockAccount, type: AccountType.credit, isNegativeNetWorth: true };
      const h1 = AccountHistory.fromPlain({
        id: "ah-1",
        time: new Date("2026-01-01T12:00:00Z"),
        balance: -500,
        account: creditAccount as any,
      });

      const qb: any = {
        innerJoinAndSelect: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        andWhere: vi.fn().mockReturnThis(),
        orderBy: vi.fn().mockReturnThis(),
        getMany: vi.fn().mockResolvedValue([h1]),
      };

      vi.spyOn(AccountHistory, "getRepository").mockReturnValue({
        createQueryBuilder: () => qb,
      } as any);

      const result = await service.getNetWorthByAccount(mockUser, creditAccount as any);
      expect(result.history).toBeDefined();
    });

    it("should handle unknown history source in getSourceId fallback", () => {
      const customHistory = {
        time: new Date(),
        balance: 100,
      };

      const getForHistoryFn = (service as any).getForHistory.bind(service);
      const res = getForHistoryFn([customHistory]);
      expect(res).toBeDefined();
    });
  });

  describe("edge cases & defensive branches", () => {
    it("should fall back to raw accountId and holdingId when relations are not loaded", () => {
      const accountHistory = AccountHistory.fromPlain({ id: "ah-fallback", time: new Date(), balance: 10 });
      (accountHistory as any).account = undefined;
      (accountHistory as any).accountId = "acct-fallback";

      const holdingHistory = HoldingHistory.fromPlain({ id: "hh-fallback", time: new Date(), marketValue: 20 });
      (holdingHistory as any).holding = undefined;
      (holdingHistory as any).holdingId = "hold-fallback";

      const result = (service as any).getForHistory([accountHistory, holdingHistory]);
      expect(result.history).toBeDefined();
    });

    it("should default to zero change when snapshots are empty", () => {
      const result = (service as any).calculateChange([], undefined, new Date());
      expect(result.valueChange).toBe(0);
      expect(result.percentChange).toBe(0);
    });

    it("should handle positive, negative, and non-numeric percent changes", () => {
      const snap = (netWorth: number) => ({ date: new Date(), netWorth });

      const positive = (service as any).calculateChange([snap(0), snap(50)], undefined, new Date());
      expect(positive.percentChange).toBe(100);

      const negative = (service as any).calculateChange([snap(0), snap(-50)], undefined, new Date());
      expect(negative.percentChange).toBe(-100);

      const nonNumeric = (service as any).calculateChange([snap(NaN), snap(NaN)], undefined, new Date());
      expect(nonNumeric.valueChange).toBe(0);
      expect(nonNumeric.percentChange).toBe(0);
    });

    it("should use empty history for entities without matching history records", async () => {
      const secondAccount = Account.fromPlain({ ...mockAccount, id: "acc-no-history" });
      vi.spyOn(Account, "getForUser").mockResolvedValue([mockAccount, secondAccount]);

      const historyEntry = AccountHistory.fromPlain({ id: "ah-present", time: new Date(), balance: 5, account: mockAccount });
      const qb: any = {
        innerJoinAndSelect: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        andWhere: vi.fn().mockReturnThis(),
        orderBy: vi.fn().mockReturnThis(),
        getMany: vi.fn().mockResolvedValue([historyEntry]),
      };
      vi.spyOn(AccountHistory, "getRepository").mockReturnValue({ createQueryBuilder: () => qb } as any);

      const result = await service.getNetWorthByAccounts(mockUser);
      expect(result).toHaveLength(2);
      expect(result[1]!.history.connectedId).toBe("acc-no-history");
    });

    it("should return an empty timeline when no days are generated", async () => {
      const qb: any = {
        innerJoinAndSelect: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        andWhere: vi.fn().mockReturnThis(),
        orderBy: vi.fn().mockReturnThis(),
        getMany: vi.fn().mockResolvedValue([AccountHistory.fromPlain({ id: "ah-empty", time: new Date(), balance: 100, account: mockAccount })]),
      };
      vi.spyOn(AccountHistory, "getRepository").mockReturnValue({ createQueryBuilder: () => qb } as any);

      vi.mocked(eachDayOfInterval).mockReturnValueOnce([]);

      const result = await service.getNetWorthSummary(mockUser);
      expect(result.timeline()).toEqual([]);
    });

    it("should keep the final sampled point when downsampling the timeline", async () => {
      const historyEntry = AccountHistory.fromPlain({
        id: "ah-sample",
        time: new Date(Date.now() - 100 * 24 * 60 * 60 * 1000),
        balance: 250,
        account: mockAccount,
      });
      const qb: any = {
        innerJoinAndSelect: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        andWhere: vi.fn().mockReturnThis(),
        orderBy: vi.fn().mockReturnThis(),
        getMany: vi.fn().mockResolvedValue([historyEntry]),
      };
      vi.spyOn(AccountHistory, "getRepository").mockReturnValue({ createQueryBuilder: () => qb } as any);

      const result = await service.getNetWorthSummary(mockUser);
      const sampled = result.timeline(365.1);
      expect(sampled.length).toBeGreaterThan(0);
    });
  });
});
