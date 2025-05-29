import { Account } from "@common";
import { DBBase } from "./base";

/** This holding class keeps track of an investment holding value */
export class Holding extends DBBase {
  currency: string;
  costBasis: string;
  /** A description of what this holding is */
  description: string;
  /** The current market value */
  marketValue: string;
  /** The current purchase price */
  purchasePrice: string;
  /** Total number of shares, including fractional */
  shares: number;
  /** The symbol for this holding */
  symbol: string;

  /** The account this holding is associated to */
  account: Account;

  constructor(
    currency: string,
    costBasis: string,
    description: string,
    marketValue: string,
    purchasePrice: string,
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
