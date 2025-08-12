import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/model/database.base";
import { Holding } from "@backend/model/holding";
import { ManyToOne } from "typeorm";

/** This class provides information for a historical stock data. */
@DatabaseDecorators.entity()
export class HoldingHistory extends DatabaseBase {
  /** The holding this history is associated to */
  @ManyToOne(() => Holding, (h) => h.id, { eager: true, onDelete: "CASCADE" })
  holding: Holding;

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

  constructor(costBasis: number, marketValue: number, purchasePrice: number, shares: number, holding: Holding) {
    super();
    this.costBasis = costBasis;
    this.marketValue = marketValue;
    this.purchasePrice = purchasePrice;
    this.shares = shares;
    this.holding = holding;
  }
}
