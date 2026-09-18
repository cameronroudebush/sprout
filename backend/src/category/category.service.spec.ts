import { setupTests } from "@backend/test/helpers";
setupTests();

import { CategoryService } from "@backend/category/category.service";
import { TestEntities } from "@backend/test/entities";
import { Transaction } from "@backend/transaction/model/transaction.model";

describe("CategoryService", () => {
  let service: CategoryService;
  const user = TestEntities.user;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new CategoryService();
  });

  describe("getStats", () => {
    it("should query stats with year and month filter", async () => {
      const mockQueryBuilder: any = {
        innerJoin: jest.fn().mockReturnThis(),
        leftJoin: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        addSelect: jest.fn().mockReturnThis(),
        groupBy: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        getRawMany: jest.fn().mockResolvedValue([
          { category_name: "Groceries", total: 5 },
          { category_name: "Utilities", total: 2 },
        ]),
      };

      jest.spyOn(Transaction, "getRepository").mockReturnValue({
        createQueryBuilder: jest.fn().mockReturnValue(mockQueryBuilder),
      } as any);

      const stats = await service.getStats(user, 2026, 6, undefined, "acc-1");

      expect(mockQueryBuilder.andWhere).toHaveBeenCalledWith("account.id = :accountId", {
        accountId: "acc-1",
      });
      expect(stats.categoryCount).toEqual({ Groceries: 5, Utilities: 2 });
    });

    it("should query stats with year only filter", async () => {
      const mockQueryBuilder: any = {
        innerJoin: jest.fn().mockReturnThis(),
        leftJoin: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        addSelect: jest.fn().mockReturnThis(),
        groupBy: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        getRawMany: jest.fn().mockResolvedValue([{ category_name: "Rent", total: 12 }]),
      };

      jest.spyOn(Transaction, "getRepository").mockReturnValue({
        createQueryBuilder: jest.fn().mockReturnValue(mockQueryBuilder),
      } as any);

      const stats = await service.getStats(user, 2026);

      expect(stats.categoryCount).toEqual({ Rent: 12 });
    });

    it("should query stats with day, month, and year filter", async () => {
      const mockQueryBuilder: any = {
        innerJoin: jest.fn().mockReturnThis(),
        leftJoin: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        addSelect: jest.fn().mockReturnThis(),
        groupBy: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        getRawMany: jest.fn().mockResolvedValue([]),
      };

      jest.spyOn(Transaction, "getRepository").mockReturnValue({
        createQueryBuilder: jest.fn().mockReturnValue(mockQueryBuilder),
      } as any);

      const stats = await service.getStats(user, 2026, 6, 15);

      expect(stats.categoryCount).toEqual({});
    });
  });
});
