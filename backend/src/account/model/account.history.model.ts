import { Account } from "@backend/account/model/account.model";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
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
