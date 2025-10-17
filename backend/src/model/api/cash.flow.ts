import { Account } from "@backend/model/account";
import { Base } from "@backend/model/base";
import { endOfDay, endOfMonth, isValid, startOfDay, startOfMonth } from "date-fns";
import { Between } from "typeorm";

/** Defines a request for what kind of data we want */
export class CashFlowRequest extends Base {
  /** An account we want data for specifically */
  account?: Account;
  /** The year we want data for */
  year: number;
  /** The month we want data for */
  month: number;
  /** A day we can optionally also get data for */
  day?: number;

  constructor(year: number, month: number, account?: Account, day?: number) {
    super();
    this.year = year;
    this.month = month;
    this.account = account;
    this.day = day;
  }

  /** Returns the year/month/day from the request in a date object */
  get queryDate() {
    return new Date(this.year, this.month - 1, this.day ?? 1);
  }

  /** Returns the where clause for the date between the given query date information */
  get between() {
    const queryDate = this.queryDate;
    return this.day == null ? Between(startOfMonth(queryDate), endOfMonth(queryDate)) : Between(startOfDay(queryDate), endOfDay(queryDate));
  }

  /** Validates this cash flow request is suitable for querying, else throws an error */
  validate() {
    if (!isValid(this.queryDate)) throw new Error("Query date is invalid.");
  }
}
