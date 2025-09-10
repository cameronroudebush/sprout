import { Account } from "@backend/model/account";
import { Base } from "@backend/model/base";

/** An enum to define how often a subscription is billed. */
export enum BillingPeriod {
  WEEKLY = "weekly",
  BI_WEEKLY = "bi-weekly",
  MONTHLY = "monthly",
  QUARTERLY = "quarterly",
  SEMI_ANNUALLY = "semi-annually",
  YEARLY = "yearly",
  UNKNOWN = "unknown",
}

/** This class defines a subscription that has been determined from the transaction history */
export class TransactionSubscription extends Base {
  /** The description of this transaction */
  description: string;
  /** The amount of this transaction */
  amount: number;
  /** The number of these transactions we have counted */
  count: number;

  /** How often this is billed */
  period: BillingPeriod;
  /** The day this billing starts */
  startDate: Date;

  /** The account related to this subscription */
  account: Account;

  constructor(description: string, amount: number, count: number, period: BillingPeriod, startDate: Date, account: Account) {
    super();
    this.description = description;
    this.amount = amount;
    this.period = period;
    this.count = count;
    this.startDate = startDate;
    this.account = account;
  }

  /** A helper function to classify the period based on average days. */
  static classifyPeriod(days: number): BillingPeriod {
    if (days >= 6 && days <= 8) return BillingPeriod.WEEKLY;
    if (days >= 13 && days <= 16) return BillingPeriod.BI_WEEKLY;
    if (days >= 27 && days <= 32) return BillingPeriod.MONTHLY;
    if (days >= 88 && days <= 94) return BillingPeriod.QUARTERLY;
    if (days >= 178 && days <= 186) return BillingPeriod.SEMI_ANNUALLY;
    if (days >= 360 && days <= 370) return BillingPeriod.YEARLY;
    return BillingPeriod.UNKNOWN;
  }
}
