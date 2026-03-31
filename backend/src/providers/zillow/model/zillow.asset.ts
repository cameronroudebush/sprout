import { Account } from "@backend/account/model/account.model";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { ApiHideProperty } from "@nestjs/swagger";
import { Exclude } from "class-transformer";
import { JoinColumn, OneToOne } from "typeorm";

/** Database model that allows us to track zillow metadata related to an account */
@DatabaseDecorators.entity()
export class ZillowAsset extends DatabaseBase {
  /** The zillow property ID */
  @DatabaseDecorators.column({ nullable: false, unique: true })
  zpid: string;

  /** The user this account belongs to */
  @OneToOne(() => Account, { onDelete: "CASCADE" })
  @JoinColumn({ name: "accountId" })
  @ApiHideProperty()
  @Exclude()
  account: Account;

  constructor(account: Account, zpid: string) {
    super();
    this.account = account;
    this.zpid = zpid;
  }
}
