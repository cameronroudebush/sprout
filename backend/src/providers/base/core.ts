import { Transaction } from "@backend/model/transaction";
import { Account, Holding } from "@common";
import { ProviderRateLimit } from "./rate-limit";

/**
 * This class provides generic functionality that should be implemented in the various providers
 *  for automatically loading finance information.
 */
export abstract class ProviderBase {
  /** The rate limit class for this provider */
  abstract readonly rateLimit: ProviderRateLimit;

  /** Returns data from the provider to satisfy updated transaction, holdings, and accounts */
  abstract get(): Promise<Array<{ account: Account; transactions: Transaction[]; holdings: Holding[] }>>;
}
