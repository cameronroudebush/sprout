import { Account } from "@backend/account/model/account.model";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { ApiHideProperty, ApiProperty } from "@nestjs/swagger";
import { Exclude } from "class-transformer";
import { IsString } from "class-validator";
import { JoinColumn, OneToOne } from "typeorm";

/** Database model that allows us to track plaid metadata specific to an account */
@DatabaseDecorators.entity()
export class PlaidAsset extends DatabaseBase {
  /** The account Id related to plaid to link back to our specific account */
  @DatabaseDecorators.column({ nullable: false, unique: true })
  @ApiProperty({ description: "The plaid account ID" })
  @IsString()
  plaidAccountId: string;

  /** The account this metadata belongs to */
  @OneToOne(() => Account, { onDelete: "CASCADE" })
  @JoinColumn({ name: "accountId" })
  @ApiHideProperty()
  @Exclude()
  account: Account;

  constructor(account: Account, plaidAccountId: string) {
    super();
    this.account = account;
    this.plaidAccountId = plaidAccountId;
  }
}
