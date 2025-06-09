import { DatabaseDecorators } from "@backend/database/decorators";
import { Account } from "@backend/model/account";
import { DatabaseBase } from "@backend/model/database.base";
import { Holding as CommonHolding } from "@common";
import { Mixin } from "ts-mixer";
import { ManyToOne } from "typeorm";

/** This class provides historical tracking to accounts. Used for things like balance over time. */
@DatabaseDecorators.entity()
export class Holding extends Mixin(DatabaseBase, CommonHolding) {
  @ManyToOne(() => Account, (i) => i.id)
  declare account: Account;

  @DatabaseDecorators.column({ nullable: false })
  declare currency: string;

  @DatabaseDecorators.column({ nullable: false })
  declare costBasis: number;

  @DatabaseDecorators.column({ nullable: false })
  declare description: string;

  @DatabaseDecorators.column({ nullable: false })
  declare marketValue: number;

  @DatabaseDecorators.column({ nullable: false })
  declare purchasePrice: number;

  @DatabaseDecorators.column({ nullable: false })
  declare shares: number;

  @DatabaseDecorators.column({ nullable: false })
  declare symbol: string;
}
