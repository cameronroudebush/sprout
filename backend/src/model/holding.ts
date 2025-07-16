import { DatabaseDecorators } from "@backend/database/decorators";
import { Account } from "@backend/model/account";
import { DatabaseBase } from "@backend/model/database.base";
import { ManyToOne } from "typeorm";

/** This class provides historical tracking to accounts. Used for things like balance over time. */
@DatabaseDecorators.entity()
export class Holding extends DatabaseBase {
  /** The account this holding is associated to */
  @ManyToOne(() => Account, (i) => i.id, { eager: true, onDelete: "CASCADE" })
  account: Account;

  @DatabaseDecorators.column({ nullable: false })
  currency: string;

  @DatabaseDecorators.column({ nullable: false })
  costBasis: number;

  /** A description of what this holding is */
  @DatabaseDecorators.column({ nullable: false })
  description: string;

  /** The current market value */
  @DatabaseDecorators.column({ nullable: false })
  marketValue: number;

  /** The current purchase price */
  @DatabaseDecorators.column({ nullable: false })
  purchasePrice: number;

  /** Total number of shares, including fractional */
  @DatabaseDecorators.column({ nullable: false })
  shares: number;

  /** The symbol for this holding */
  @DatabaseDecorators.column({ nullable: false })
  symbol: string;

  constructor(
    currency: string,
    costBasis: number,
    description: string,
    marketValue: number,
    purchasePrice: number,
    shares: number,
    symbol: string,
    account: Account,
  ) {
    super();
    this.currency = currency;
    this.costBasis = costBasis;
    this.description = description;
    this.marketValue = marketValue;
    this.purchasePrice = purchasePrice;
    this.shares = shares;
    this.symbol = symbol;
    this.account = account;
  }
}
