import { Account } from "@backend/account/model/account.model";
import { Category } from "@backend/category/model/category.model";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { TransactionRuleType } from "@backend/transaction/model/transaction.rule.type";
import { User } from "@backend/user/model/user.model";
import { ApiHideProperty, ApiProperty } from "@nestjs/swagger";
import { Exclude } from "class-transformer";
import { IsBoolean, IsEnum, IsNotEmpty, IsNumber, IsOptional, IsString } from "class-validator";
import { JoinColumn, ManyToOne } from "typeorm";

/** This class defines a rule that allows us to organize transactions based on a rule  */
@DatabaseDecorators.entity()
export class TransactionRule extends DatabaseBase {
  @ManyToOne(() => User, (u) => u.id, { onDelete: "CASCADE" })
  @ApiHideProperty()
  @Exclude({ toPlainOnly: true })
  user: User;

  @DatabaseDecorators.column({ nullable: false, type: "varchar" })
  @IsEnum(TransactionRuleType)
  type: TransactionRuleType;

  /** This defines the value of the rule. Strings support | to split content */
  @DatabaseDecorators.column({ nullable: false })
  @IsString()
  @IsNotEmpty()
  value: string;

  /** This defines the category to set the transaction to */
  @ManyToOne(() => Category, { nullable: true, eager: true, onDelete: "SET NULL" })
  @JoinColumn({ name: "categoryId" })
  @IsOptional()
  @Exclude({ toPlainOnly: true })
  @ApiHideProperty()
  category?: Category;

  @DatabaseDecorators.column({ nullable: true })
  @ApiProperty({ description: "The Id of the category related to this transaction rule, if set.", required: false })
  @IsOptional()
  categoryId!: string;

  /** If this match should be strict. So if it should be the exact string or the exact number. */
  @DatabaseDecorators.column({ nullable: false })
  @IsBoolean()
  strict: boolean;

  /** How many transactions have been updated by this transaction rule. */
  @DatabaseDecorators.column({ nullable: false })
  @IsNumber()
  matches: number = 0;

  /** The order of priority of this value */
  @DatabaseDecorators.column({ nullable: false })
  @IsNumber()
  order: number = 0;

  /** If this rule should be executed */
  @DatabaseDecorators.column({ nullable: false })
  @IsBoolean()
  enabled: boolean = true;

  /** An account that this rule should ony apply to. */
  @ManyToOne(() => Account, (a) => a.id, { nullable: true, eager: true, onDelete: "SET NULL" })
  @JoinColumn({ name: "accountId" })
  @IsOptional()
  @ApiHideProperty()
  @Exclude({ toPlainOnly: true })
  account?: Account;

  @DatabaseDecorators.column({ nullable: true })
  @ApiProperty({ description: "The Id of the account related to this transaction rule for specific filtering.", required: false })
  @IsOptional()
  accountId?: string;

  constructor(user: User, type: TransactionRuleType, value: string, category?: Category, strict: boolean = false) {
    super();
    this.user = user;
    this.type = type;
    this.value = value;
    this.category = category;
    this.strict = strict;
  }
}
