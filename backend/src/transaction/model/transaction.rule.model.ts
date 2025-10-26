import { Category } from "@backend/category/model/category.model";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { TransactionRuleType } from "@backend/transaction/model/transaction.rule.type";
import { User } from "@backend/user/model/user.model";
import { ApiHideProperty } from "@nestjs/swagger";
import { ManyToOne } from "typeorm";

/** This class defines a rule that allows us to organize transactions based on a rule  */
@DatabaseDecorators.entity()
export class TransactionRule extends DatabaseBase {
  @ManyToOne(() => User, (u) => u.id, { onDelete: "CASCADE" })
  @ApiHideProperty()
  user: User;

  @DatabaseDecorators.column({ nullable: false, type: "varchar" })
  type: TransactionRuleType;

  /** This defines the value of the rule. Strings support | to split content */
  @DatabaseDecorators.column({ nullable: false })
  value: string;

  /** This defines the category to set the transaction to */
  @ManyToOne(() => Category, { nullable: true, eager: true, onDelete: "SET NULL" })
  category?: Category;

  /** If this match should be strict. So if it should be the exact string or the exact number. */
  @DatabaseDecorators.column({ nullable: false })
  strict: boolean;

  /** How many transactions have been updated by this transaction rule. */
  @DatabaseDecorators.column({ nullable: false })
  matches: number = 0;

  /** The order of priority of this value */
  @DatabaseDecorators.column({ nullable: false })
  order: number = 0;

  /** If this rule should be executed */
  @DatabaseDecorators.column({ nullable: false })
  enabled: boolean = true;

  constructor(user: User, type: TransactionRuleType, value: string, category?: Category, strict: boolean = false) {
    super();
    this.user = user;
    this.type = type;
    this.value = value;
    this.category = category;
    this.strict = strict;
  }
}
