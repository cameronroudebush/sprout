import { DatabaseDecorators } from "@backend/database/decorators";
import { Account } from "@backend/model/account";
import { DatabaseBase } from "@backend/model/database.base";
import { ManyToOne } from "typeorm";

@DatabaseDecorators.entity()
export class Transaction extends DatabaseBase {
  /** In the currency of the account */
  @DatabaseDecorators.column({ nullable: false })
  amount: number;

  @DatabaseDecorators.column({ nullable: false })
  description: string;
  @DatabaseDecorators.column()
  pending: boolean;
  @DatabaseDecorators.column({ nullable: false })
  category: string;

  /** The date this transaction posted */
  @DatabaseDecorators.column({ nullable: false })
  posted: Date;

  /** The account this transaction belongs to */
  @ManyToOne(() => Account, (a) => a.id, { eager: true, onDelete: "CASCADE" })
  account: Account;

  constructor(amount: number, posted: Date, description: string, category: string, pending: boolean, account: Account) {
    super();
    this.amount = amount;
    this.posted = posted;
    this.description = description;
    this.category = category;
    this.pending = pending;
    this.account = account;
  }
}
