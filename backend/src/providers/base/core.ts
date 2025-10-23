import { Account } from "@backend/account/model/account";
import { Holding } from "@backend/holding/model/holding";
import { ProviderConfig } from "@backend/providers/base/config";
import { Transaction } from "@backend/transaction/model/transaction";
import { User } from "@backend/user/model/user";
import { ProviderRateLimit } from "./rate-limit";

/**
 * This class provides generic functionality that should be implemented in the various providers
 *  for automatically loading finance information.
 */
export abstract class ProviderBase {
  constructor(public config: ProviderConfig) {}

  /** The rate limit class for this provider */
  abstract readonly rateLimit: ProviderRateLimit;

  /**
   * Returns data from the provider to satisfy updated transaction, holdings, and accounts
   *
   * @param user The user we want accounts for.
   * @param accountsOnly If we only want accounts and not included holdings or transactions.
   */
  abstract get(user: User, accountsOnly: boolean): Promise<Array<{ account: Account; transactions: Transaction[]; holdings: Holding[] }>>;
}
