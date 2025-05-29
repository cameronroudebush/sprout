import { Transaction } from "@backend/model/transaction";
import { Account, User } from "@common";
import { ProviderRateLimit } from "./rate-limit";

/**
 * This class provides generic functionality that should be implemented in the various providers
 *  for automatically loading finance information.
 */
export abstract class ProviderBase {
  /** The rate limit class for this provider */
  abstract readonly rateLimit: ProviderRateLimit;

  /** Returns the transactions for the given user */
  abstract getTransactions(user: User): Promise<Transaction[]>;

  /** Returns accounts associated to the given user */
  abstract getAccounts(user: User): Promise<Account[]>;
}
