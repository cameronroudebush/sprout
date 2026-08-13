import { Account } from "@backend/account/model/account.model";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { JoinColumn, OneToOne } from "typeorm";

/** Database model tracking individual SnapTrade account mappings to Sprout accounts. */
@DatabaseDecorators.entity()
export class SnapTradeAsset extends DatabaseBase {
  @OneToOne(() => Account, { onDelete: "CASCADE", eager: true })
  @JoinColumn()
  account: Account;

  @DatabaseDecorators.column({ type: "varchar" })
  snapTradeAccountId: string;

  constructor(account: Account, snapTradeAccountId: string) {
    super();
    this.account = account;
    this.snapTradeAccountId = snapTradeAccountId;
  }
}
