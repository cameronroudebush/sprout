import { Account } from "@backend/account/model/account.model";
import { Category } from "@backend/category/model/category.model";
import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { User } from "@backend/user/model/user.model";
import { Optional } from "@nestjs/common";
import { ApiHideProperty, ApiProperty } from "@nestjs/swagger";
import { Exclude } from "class-transformer";
import { IsNotEmpty, IsOptional, IsString } from "class-validator";
import { JoinColumn, ManyToOne } from "typeorm";

@DatabaseDecorators.entity()
@CurrencyHelper.ExposeCurrencyFields<Transaction>("amount", "account.currency")
export class Transaction extends DatabaseBase {
  /** In the currency of the account */
  @DatabaseDecorators.numericColumn({ nullable: false })
  amount: number;

  @DatabaseDecorators.column({ nullable: false })
  @IsString()
  @IsNotEmpty()
  description: string;
  @DatabaseDecorators.column()
  pending: boolean;

  /** The category this transaction belongs to. A null category signifies an unknown category. */
  @ManyToOne(() => Category, (a) => a.id, { nullable: true, eager: true, onDelete: "SET NULL" })
  @JoinColumn({ name: "categoryId" })
  @IsOptional()
  @ApiHideProperty()
  @Exclude({ toPlainOnly: true })
  category?: Category;

  @DatabaseDecorators.column({ nullable: true })
  @ApiProperty({ description: "The Id of the category related to this transaction, if set.", required: false })
  @IsOptional()
  categoryId!: string;

  /** The date this transaction posted */
  @DatabaseDecorators.column({ nullable: false })
  posted: Date;

  /** The account this transaction belongs to */
  @ManyToOne(() => Account, (a) => a.id, { eager: true, onDelete: "CASCADE" })
  @JoinColumn({ name: "accountId" })
  @ApiHideProperty()
  @Exclude({ toPlainOnly: true })
  account: Account;

  @DatabaseDecorators.column({ nullable: false })
  @ApiProperty({ description: "The Id of the account related to this transaction." })
  accountId!: string;

  /** Any extra data that we want to store as JSON */
  @DatabaseDecorators.jsonColumn({ nullable: true })
  extra?: object;

  /** Tracks if this transaction was manually edited by the user. Used to prevent automation from overwriting it for transactional rules. This will be rest if automation does update it. */
  @DatabaseDecorators.jsonColumn({ nullable: true })
  @Optional()
  manuallyEdited?: boolean = false;

  constructor(amount: number, posted: Date, description: string, category: Category | undefined, pending: boolean, account: Account) {
    super();
    this.amount = amount;
    this.posted = posted;
    this.description = description;
    this.category = category;
    this.pending = pending;
    this.account = account;
  }

  /** Given a list of these transactions, updates them to the target currency of the user config. This will edit in place. */
  static convertListToTargetCurrency(transactions: Array<Transaction>, user: User) {
    CurrencyHelper.convertList(transactions, "amount", "account.currency", user);
    return transactions;
  }
}
