import { DatabaseDecorators } from "@backend/database/decorators";
import { CategoryStats } from "@backend/model/api/category.stats";
import { DatabaseBase } from "@backend/model/database.base";
import { Transaction } from "@backend/model/transaction";
import { User } from "@backend/model/user";
import { subDays } from "date-fns";
import { startCase } from "lodash";
import { JoinColumn, ManyToOne } from "typeorm";

/** This class defines a category that a transcription belongs to */
@DatabaseDecorators.entity()
@DatabaseDecorators.compositeUnique<Category>("name", "userId")
export class Category extends DatabaseBase {
  /** The name when no category is defined for a transaction */
  static UNKNOWN_NAME = "Unknown";

  /** The category this user belongs to */
  @ManyToOne(() => User, (u) => u.id, { onDelete: "CASCADE" })
  @JoinColumn({ name: "userId" })
  user: User;
  @DatabaseDecorators.column({ nullable: false })
  userId!: number;

  /** The name of this category */
  @DatabaseDecorators.column({ nullable: false })
  name: string;

  /** If this account type should be considered an expense or income */
  @DatabaseDecorators.column({ nullable: false })
  type: "income" | "expense";

  /** The parent category this category belongs to */
  @ManyToOne(() => Category, { nullable: true, onDelete: "SET NULL", eager: false })
  parentCategory?: Category;

  constructor(user: User, name: string, type: Category["type"], parentCategory?: Category) {
    super();
    this.user = user;
    this.name = name;
    this.type = type;
    this.parentCategory = parentCategory;
  }

  /**
   * Returns some default categories that the given user will be given
   *
   * This **will** return the categories in order for nesting
   */
  static getDefaultCategoriesForUser(user: User) {
    const categoriesToInsert: Category[] = [];
    const foodAndDrink = new Category(user, "Food & Drink", "expense");
    categoriesToInsert.push(foodAndDrink);
    categoriesToInsert.push(new Category(user, "Groceries", "expense", foodAndDrink));
    categoriesToInsert.push(new Category(user, "Restaurants", "expense", foodAndDrink));

    const shopping = new Category(user, "Shopping", "expense");
    categoriesToInsert.push(shopping);
    categoriesToInsert.push(new Category(user, "Online Shopping", "expense", shopping));

    categoriesToInsert.push(new Category(user, "Utilities", "expense"));
    categoriesToInsert.push(new Category(user, "Housing", "expense"));
    categoriesToInsert.push(new Category(user, "Transportation", "expense"));
    categoriesToInsert.push(new Category(user, "Healthcare", "expense"));
    categoriesToInsert.push(new Category(user, "Entertainment", "expense"));
    categoriesToInsert.push(new Category(user, "Pets", "expense"));
    categoriesToInsert.push(new Category(user, "Income", "income"));
    return categoriesToInsert;
  }

  /** Returns the default, unknown, category for transactions that we can't determine the category of. */
  static getUnknownCategory(user: User) {
    return Category.findOne({ where: { user: { id: user.id }, name: "Unknown" } });
  }

  /** Returns stat information for all categories for the given user */
  static async getStats(user: User, days?: number) {
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

    const categoryCount: { [name: string]: number } = Object.fromEntries(finalResults.map((x) => [x.category_name, x.total]));

    return CategoryStats.fromPlain({ categoryCount });
  }

  /** Get's a category by the given name or returns the existing one if it's found. */
  static async getOrCreate(category: string | undefined, user: User, type: Category["type"] = "expense") {
    if (category == null) return await this.getUnknownCategory(user);
    else {
      const name = startCase(category);
      const matchingCategory = Category.findOne({ where: { name: name, user: { id: user.id }, type: type } });
      if (matchingCategory) return matchingCategory;
      else return await Category.fromPlain({ name, user, type }).insert();
    }
  }
}
