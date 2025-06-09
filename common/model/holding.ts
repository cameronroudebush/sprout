import { Account } from "@common";
import { DBBase } from "./base";

/** This holding class keeps track of an investment holding value */
export class Holding extends DBBase {
  currency: string;
  costBasis: number;
  /** A description of what this holding is */
  description: string;
  /** The current market value */
  marketValue: number;
  /** The current purchase price */
  purchasePrice: number;
  /** Total number of shares, including fractional */
  shares: number;
  /** The symbol for this holding */
  symbol: string;

  /** The account this holding is associated to */
  account: Account;

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
