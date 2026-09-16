import { Category } from "@backend/category/model/category.model";
import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { User } from "@backend/user/model/user.model";
import { ApiHideProperty, ApiProperty } from "@nestjs/swagger";
import { Exclude } from "class-transformer";
import { IsNotEmpty, IsNumber, IsOptional, Min } from "class-validator";
import { JoinColumn, ManyToOne } from "typeorm";

/**
 * This class defines a budget allocation for a specific category for a user.
 */
@DatabaseDecorators.entity()
@DatabaseDecorators.compositeUnique<Budget>("userId", "categoryId")
@CurrencyHelper.ExposeCurrencyFields<Budget>("amount", "user.config.currency")
export class Budget extends DatabaseBase {
  /** The user this budget belongs to */
  @ManyToOne(() => User, (u) => u.id, { onDelete: "CASCADE" })
  @JoinColumn({ name: "userId" })
  @ApiHideProperty()
  user!: User;

  @DatabaseDecorators.column({ nullable: false })
  @ApiHideProperty()
  userId!: string;

  /** The category this budget target applies to */
  @ManyToOne(() => Category, (c) => c.id, { eager: true, onDelete: "CASCADE" })
  @JoinColumn({ name: "categoryId" })
  @IsOptional()
  @ApiHideProperty()
  @Exclude({ toPlainOnly: true })
  category!: Category;

  @DatabaseDecorators.column({ nullable: false })
  @ApiProperty({ description: "The ID of the category for this budget." })
  @IsNotEmpty()
  categoryId!: string;

  /** The monthly target amount for this category in the user's primary currency */
  @DatabaseDecorators.numericColumn({ nullable: false })
  @ApiProperty({ description: "The monthly target budget amount.", example: 500.0 })
  @IsNumber()
  @Min(0)
  amount!: number;

  constructor(user: User, category: Category, amount: number) {
    super();
    this.user = user;
    this.category = category;
    if (category) this.categoryId = category.id;
    this.amount = amount;
  }

  /** Given a list of budgets, converts their amounts to the target currency of the user config. */
  static convertListToTargetCurrency(budgets: Array<Budget>, user: User) {
    CurrencyHelper.convertList(budgets, "amount", "user.config.currency", user);
    return budgets;
  }
}
