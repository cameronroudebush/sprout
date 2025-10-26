import { CategoryStats } from "@backend/category/model/api/category.stats.dto";
import { Category } from "@backend/category/model/category.model";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";
import { subDays } from "date-fns";

/** This class contains re-usable functions for the {@link Category} model */
@Injectable()
export class CategoryService {
  /** Returns stat information for all categories for the given user */
  async getStats(user: User, days?: number) {
    const results = Transaction.getRepository()
      .createQueryBuilder("t")
      // Join account to filter by user
      .innerJoin("t.account", "account")
      // Join category for grouping
      .leftJoin("t.category", "category")
      // First filter: Must belong to the specified user
      .where("account.userId = :userId", { userId: user.id });

    // Second filter: Must be within the date range, only if given
    if (days != null) {
      results.andWhere("t.posted >= :startDate", { startDate: subDays(new Date(), days) });
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
