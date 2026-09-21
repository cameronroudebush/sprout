import { setupTests } from "@backend/test/helpers";
setupTests();

import { CategoryService } from "@backend/category/category.service";
import { TestEntities } from "@backend/test/entities";
import { Transaction } from "@backend/transaction/model/transaction.model";

describe("CategoryService", () => {
  let service: CategoryService;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.clearAllMocks();
    service = new CategoryService();
  });

  describe("getStats", () => {
    it("should query stats with year and month filter", async () => {
      const mockQueryBuilder: any = {
        innerJoin: vi.fn().mockReturnThis(),
        leftJoin: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        andWhere: vi.fn().mockReturnThis(),
        select: vi.fn().mockReturnThis(),
        addSelect: vi.fn().mockReturnThis(),
        groupBy: vi.fn().mockReturnThis(),
        orderBy: vi.fn().mockReturnThis(),
        getRawMany: vi.fn().mockResolvedValue([
          { category_name: "Groceries", total: 5 },
          { category_name: "Utilities", total: 2 },
        ]),
      };

      vi.spyOn(Transaction, "getRepository").mockReturnValue({
        createQueryBuilder: vi.fn().mockReturnValue(mockQueryBuilder),
      } as any);

      const stats = await service.getStats(user, 2026, 6, undefined, "acc-1");

      expect(mockQueryBuilder.andWhere).toHaveBeenCalledWith("account.id = :accountId", {
        accountId: "acc-1",
      });
      expect(stats.categoryCount).toEqual({ Groceries: 5, Utilities: 2 });
    });

    it("should query stats with year only filter", async () => {
      const mockQueryBuilder: any = {
        innerJoin: vi.fn().mockReturnThis(),
        leftJoin: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        andWhere: vi.fn().mockReturnThis(),
        select: vi.fn().mockReturnThis(),
        addSelect: vi.fn().mockReturnThis(),
        groupBy: vi.fn().mockReturnThis(),
        orderBy: vi.fn().mockReturnThis(),
        getRawMany: vi.fn().mockResolvedValue([{ category_name: "Rent", total: 12 }]),
      };

      vi.spyOn(Transaction, "getRepository").mockReturnValue({
        createQueryBuilder: vi.fn().mockReturnValue(mockQueryBuilder),
      } as any);

      const stats = await service.getStats(user, 2026);

      expect(stats.categoryCount).toEqual({ Rent: 12 });
    });

    it("should query stats with day, month, and year filter", async () => {
      const mockQueryBuilder: any = {
        innerJoin: vi.fn().mockReturnThis(),
        leftJoin: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        andWhere: vi.fn().mockReturnThis(),
        select: vi.fn().mockReturnThis(),
        addSelect: vi.fn().mockReturnThis(),
        groupBy: vi.fn().mockReturnThis(),
        orderBy: vi.fn().mockReturnThis(),
        getRawMany: vi.fn().mockResolvedValue([]),
      };

      vi.spyOn(Transaction, "getRepository").mockReturnValue({
        createQueryBuilder: vi.fn().mockReturnValue(mockQueryBuilder),
      } as any);

      const stats = await service.getStats(user, 2026, 6, 15);

      expect(stats.categoryCount).toEqual({});
    });
  });
});
