import { CategoryType } from "@backend/category/model/category.type";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { User } from "@backend/user/model/user.model";
import { ApiHideProperty, ApiProperty } from "@nestjs/swagger";
import { IsEnum, IsNotEmpty, IsObject, IsOptional, IsString } from "class-validator";
import { startCase } from "lodash";
import { JoinColumn, ManyToOne } from "typeorm";

/** This class defines a category that a transcription belongs to */
@DatabaseDecorators.entity()
@DatabaseDecorators.compositeUnique<Category>("name", "userId", "parentCategoryId")
export class Category extends DatabaseBase {
  /** The name when no category is defined for a transaction */
  static UNKNOWN_NAME = "Unknown";

  /** The category this user belongs to */
  @ManyToOne(() => User, (u) => u.id, { onDelete: "CASCADE" })
  @JoinColumn({ name: "userId" })
  @ApiHideProperty()
  user: User;
  @DatabaseDecorators.column({ nullable: false })
  @ApiHideProperty()
  userId!: string;

  /** The name of this category */
  @ApiProperty({ description: "The name of the category", example: "Groceries" })
  @IsString()
  @IsNotEmpty()
  @DatabaseDecorators.column({ nullable: false })
  name: string;

  /** If this account type should be considered an expense or income */
  @DatabaseDecorators.column({ nullable: false })
  @IsEnum(CategoryType)
  type: CategoryType;

  /** The parent category this category belongs to */
  @ManyToOne(() => Category, { nullable: true, onDelete: "SET NULL", eager: false })
  @JoinColumn({ name: "parentCategoryId" })
  @IsOptional()
  @IsObject()
  @ApiProperty({ type: Category })
  parentCategory?: Category;
  @DatabaseDecorators.column({ nullable: true })
  @ApiHideProperty()
  parentCategoryId!: string;

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
    const foodAndDrink = new Category(user, "Food & Drink", CategoryType.expense);
    categoriesToInsert.push(foodAndDrink);
    categoriesToInsert.push(new Category(user, "Groceries", CategoryType.expense, foodAndDrink));
    categoriesToInsert.push(new Category(user, "Restaurants", CategoryType.expense, foodAndDrink));

    const shopping = new Category(user, "Shopping", CategoryType.expense);
    categoriesToInsert.push(shopping);
    categoriesToInsert.push(new Category(user, "Online Shopping", CategoryType.expense, shopping));

    categoriesToInsert.push(new Category(user, "Utilities", CategoryType.expense));
    categoriesToInsert.push(new Category(user, "Housing", CategoryType.expense));
    categoriesToInsert.push(new Category(user, "Transportation", CategoryType.expense));
    categoriesToInsert.push(new Category(user, "Healthcare", CategoryType.expense));
    categoriesToInsert.push(new Category(user, "Entertainment", CategoryType.expense));
    categoriesToInsert.push(new Category(user, "Pets", CategoryType.expense));
    categoriesToInsert.push(new Category(user, "Income", CategoryType.income));
    return categoriesToInsert;
  }

  /** Returns the default, unknown, category for transactions that we can't determine the category of. */
  static getUnknownCategory(user: User) {
    return Category.findOne({ where: { user: { id: user.id }, name: "Unknown" } });
  }

  /** Get's a category by the given name or returns the existing one if it's found. */
  static async getOrCreate(category: string | undefined, user: User, type: CategoryType.expense = CategoryType.expense) {
    if (category == null) return await this.getUnknownCategory(user);
    else {
      const name = startCase(category);
      const matchingCategory = Category.findOne({ where: { name: name, user: { id: user.id }, type: type } });
      if (matchingCategory) return matchingCategory;
      else return await Category.fromPlain({ name, user, type }).insert();
    }
  }
}
