import { DatabaseDecorators } from "@backend/database/decorators";
import { Account } from "@backend/model/account";
import { DatabaseBase } from "@backend/model/database.base";
import { ManyToOne } from "typeorm";

/** This class provides historical tracking to accounts. Used for things like balance over time. */
@DatabaseDecorators.entity()
export class AccountHistory extends DatabaseBase {
  @ManyToOne(() => Account, (i) => i.id, { eager: true, onDelete: "CASCADE" })
  declare account: Account;

  @DatabaseDecorators.column({ nullable: false })
  declare time: Date;
  @DatabaseDecorators.numericColumn({ nullable: false })
  declare balance: number;
  @DatabaseDecorators.numericColumn({ nullable: false })
  declare availableBalance: number;
}
