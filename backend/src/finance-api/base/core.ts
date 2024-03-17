import { User } from "@common";

/**
 * This class provides generic functionality that should be implemented in the various API handlings
 *  for the financial services.
 */
export abstract class FinanceAPIBase {
  /**
   * Returns the transactions associated to the given user.
   */
  abstract getTransactions(user: User): Promise<any>;

  /** Returns accounts associated to the given user */
  abstract getAccounts(user: User): Promise<any>;
}
