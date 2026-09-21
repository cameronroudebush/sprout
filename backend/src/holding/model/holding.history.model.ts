import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { User } from "@backend/user/model/user.model";
import { subDays } from "date-fns";
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

  /**
   * Given a holding, inserts a one-day-old holding history intended to be used with new holdings.
   * This ensures initial historical frames (1-Day change) establish a baseline rather than evaluating against 0.
   *
   * @param holding The newly persisted holding entity.
   * @param includeValues If true, backdates the current market value. If false, initializes baseline values to 0.
   */
  static async insertForNewHolding(holding: Holding, includeValues = true): Promise<HoldingHistory> {
    const history = new HoldingHistory();
    history.holding = holding;
    history.time = subDays(new Date(), 1);
    history.costBasis = includeValues ? holding.costBasis : 0;
    history.marketValue = includeValues ? holding.marketValue : 0;
    history.purchasePrice = includeValues ? holding.purchasePrice : 0;
    history.shares = includeValues ? holding.shares : 0;
    return await history.insert();
  }
}
