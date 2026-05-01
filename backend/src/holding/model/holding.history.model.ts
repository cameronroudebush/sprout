import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { User } from "@backend/user/model/user.model";
import { ManyToOne } from "typeorm";
import { Holding } from "./holding.model";

/** This class provides information for a historical stock data. */
@DatabaseDecorators.entity()
@CurrencyHelper.ExposeCurrencyFields<HoldingHistory>("costBasis", "holding.currency")
@CurrencyHelper.ExposeCurrencyFields<HoldingHistory>("marketValue", "holding.currency")
@CurrencyHelper.ExposeCurrencyFields<HoldingHistory>("purchasePrice", "holding.currency")
export class HoldingHistory extends DatabaseBase {
  /** The holding this history is associated to */
  @ManyToOne(() => Holding, (h) => h.id, { eager: true, onDelete: "CASCADE" })
  holding!: Holding;

  @DatabaseDecorators.column({ nullable: false })
  declare time: Date;

  @DatabaseDecorators.numericColumn({ nullable: false })
  declare costBasis: number;
  @DatabaseDecorators.numericColumn({ nullable: false })
  declare marketValue: number;
  @DatabaseDecorators.numericColumn({ nullable: false })
  declare purchasePrice: number;
  @DatabaseDecorators.numericColumn({ nullable: false })
  declare shares: number;

  /** Given a list of these holding histories, updates them to the target currency of the user config. This will edit in place. */
  static convertListToTargetCurrency(arr: Array<HoldingHistory>, user: User) {
    CurrencyHelper.convertList(arr, ["costBasis", "marketValue", "purchasePrice"], "holding.currency", user);
    return arr;
  }
}
