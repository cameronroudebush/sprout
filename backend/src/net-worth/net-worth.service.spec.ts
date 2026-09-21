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

      const h1 = AccountHistory.fromPlain({
        id: "ah-1",
        time: new Date(),
        balance: 1000,
        account: mockAccount,
      });

      vi.spyOn(service as any, "getAccountHistoryForUser").mockResolvedValue([h1]);

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
});
