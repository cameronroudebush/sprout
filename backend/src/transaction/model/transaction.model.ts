import { Account } from "@backend/account/model/account.model";
import { Category } from "@backend/category/model/category.model";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { IsNotEmpty, IsObject, IsOptional, IsString } from "class-validator";
import { ManyToOne } from "typeorm";

@DatabaseDecorators.entity()
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
  @IsOptional()
  @IsObject()
  category?: Category;

  /** The date this transaction posted */
  @DatabaseDecorators.column({ nullable: false })
  posted: Date;

  /** The account this transaction belongs to */
  @ManyToOne(() => Account, (a) => a.id, { eager: true, onDelete: "CASCADE" })
  account: Account;

  /** Any extra data that we want to store as JSON */
  @DatabaseDecorators.jsonColumn({ nullable: true })
  extra?: object;

  constructor(amount: number, posted: Date, description: string, category: Category | undefined, pending: boolean, account: Account) {
    super();
    this.amount = amount;
    this.posted = posted;
    this.description = description;
    this.category = category;
    this.pending = pending;
    this.account = account;
  }
}
