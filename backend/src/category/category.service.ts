import { CategoryStats } from "@backend/category/model/api/category.stats.dto";
import { Category } from "@backend/category/model/category.model";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";
import { endOfMonth, startOfMonth } from "date-fns";
import { Between } from "typeorm";

/** This class contains re-usable functions for the {@link Category} model */
@Injectable()
export class CategoryService {
  /** Returns stat information for all categories for the given user */
  async getStats(user: User, year: number, month?: number, day?: number, accountId?: string) {
    // Adjust month so it's 0 index
    if (month) month -= 1;
    const results = Transaction.getRepository()
      .createQueryBuilder("t")
      // Join account to filter by user
      .innerJoin("t.account", "account")
      // Join category for grouping
      .leftJoin("t.category", "category")
      // First filter: Must belong to the specified user and optionally account
      .where("account.userId = :userId", { userId: user.id });

    if (accountId != null) {
      results.andWhere("account.id = :accountId", { accountId: accountId });
    }

    // Second filter: Must be within the date range, only if given
    if (month != null && year != null) {
      const queryDate = new Date(year, month ?? 0, 1);
      results.andWhere({
        posted: Between(startOfMonth(queryDate), endOfMonth(queryDate)),
      });
    } else if (year != null) {
      results.andWhere("t.posted BETWEEN :startOfYear AND :endOfYear", {
        startOfYear: new Date(year, 0, 1),
        endOfYear: new Date(year, 11, 31, 23, 59, 59, 999),
      });
    } else if (day != null && month != null && year != null) {
      const queryDate = new Date(year, month, day);
      results.andWhere({
        posted: queryDate,
      });
    }

    const finalResults = await results
      .select(`COALESCE(category.name, '${Category.UNKNOWN_NAME}')`, "category_name")
      .addSelect("COUNT(t.id)", "total")
      .groupBy("category_name")
      .orderBy("category_name", "ASC")
      .getRawMany();

    return CategoryStats.fromPlain({ categoryCount: Object.fromEntries(finalResults.map((x) => [x.category_name, x.total])) });
  }
}
