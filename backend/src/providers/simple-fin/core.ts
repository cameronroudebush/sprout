import { Transaction } from "@backend/model/transaction";
import { Account, User } from "@common";
import { ProviderBase } from "../base/core";
import { ProviderRateLimit } from "../base/rate-limit";

/**
 * This provider adds automated account syncing using the SimpleFIN provider.
 */
export class SimpleFINProvider extends ProviderBase {
  override rateLimit: ProviderRateLimit = new ProviderRateLimit("simple-fin", 24);

  override getTransactions(_user: User): Promise<Transaction[]> {
    throw new Error("Method not implemented.");
  }

  override getAccounts(_user: User): Promise<Account[]> {
    throw new Error("Method not implemented.");
  }

  /** Fetches data from SimpleFIN via rest requests */
  async fetchData() {
    // TODO
  }
}
