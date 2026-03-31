import { Account } from "@backend/account/model/account.model";
import { Holding } from "@backend/holding/model/holding.model";
import { BaseProviderConfig } from "@backend/providers/base/config";
import { ProviderConfig } from "@backend/providers/base/model/provider.config.model";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { HttpService } from "@nestjs/axios";
import { ProviderRateLimit } from "./rate-limit";

/**
 * This class provides generic functionality that should be implemented in the various providers
 *  for automatically loading finance information.
 */
export abstract class ProviderBase {
  /** The configuration related to this provider */
  abstract config: ProviderConfig;

  /** Gets the app configuration via the Configuration class */
  abstract getAppConfiguration: { (): BaseProviderConfig };

  constructor(public httpService: HttpService) {}

  /** The rate limit class for this provider */
  abstract readonly rateLimit: { (user?: User): ProviderRateLimit };

  /**
   * Returns data from the provider to satisfy updated transaction, holdings, and accounts
   *
   * @param user The user we want accounts for.
   * @param accountsOnly If we only want accounts and not included holdings or transactions.
   */
  abstract get(user: User, accountsOnly: boolean): Promise<Array<{ account: Account; transactions?: Transaction[]; holdings?: Holding[] }>>;
}
