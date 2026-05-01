import { Account } from "@backend/account/model/account.model";
import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { User } from "@backend/user/model/user.model";
import { ApiHideProperty } from "@nestjs/swagger";
import { Exclude } from "class-transformer";
import { ManyToOne, Not } from "typeorm";
import { HoldingHistory } from "./holding.history.model";

/** This class provides information for a current stock that is associated to an account. */
@DatabaseDecorators.entity()
@CurrencyHelper.ExposeCurrencyFields<Holding>("marketValue", "currency")
@CurrencyHelper.ExposeCurrencyFields<Holding>("costBasis", "currency")
@CurrencyHelper.ExposeCurrencyFields<Holding>("purchasePrice", "currency")
export class Holding extends DatabaseBase {
  /** The account this holding is associated to */
  @ManyToOne(() => Account, (i) => i.id, { eager: true, onDelete: "CASCADE" })
  account: Account;

  @DatabaseDecorators.column({ nullable: false })
  @Exclude({ toPlainOnly: true })
  @ApiHideProperty()
  currency: string;

  @DatabaseDecorators.numericColumn({ nullable: false })
  costBasis: number;

  /** A description of what this holding is */
  @DatabaseDecorators.column({ nullable: false })
  description: string;

  /** The current market value */
  @DatabaseDecorators.numericColumn({ nullable: false })
  marketValue: number;

  /** The current purchase price */
  @DatabaseDecorators.numericColumn({ nullable: false })
  purchasePrice: number;

  /** Total number of shares, including fractional */
  @DatabaseDecorators.numericColumn({ nullable: false })
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

  /** Given an account, returns all holdings in the database for that account. */
  static getForAccount(account: Account) {
    return Holding.find({ where: { account: { id: account.id }, shares: Not(0) } });
  }

  /** Turns this holding to act like a holding history for today */
  toAccountHistory(date = new Date()) {
    return HoldingHistory.fromPlain({
      costBasis: this.costBasis,
      marketValue: this.marketValue,
      purchasePrice: this.purchasePrice,
      shares: this.shares,
      holding: this,
      time: date,
    });
  }

  /** Given a list of these holdings, updates them to the target currency of the user config. This will edit in place. */
  static convertListToTargetCurrency(arr: Array<Holding>, user: User) {
    CurrencyHelper.convertList(arr, ["costBasis", "marketValue", "purchasePrice"], "currency", user);
    return arr;
  }
}
