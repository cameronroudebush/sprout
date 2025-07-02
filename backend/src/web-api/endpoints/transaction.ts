import { Account } from "@backend/model/account";
import { Transaction } from "@backend/model/transaction";
import { RestBody, RestEndpoints, TransactionRequest, User } from "@common";
import { RestMetadata } from "../metadata";

export class TransactionAPI {
  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.get, "POST"))
  async getTransactions(request: RestBody, user: User) {
    const parsedRequest = TransactionRequest.fromPlain(request.payload);
    return await Transaction.find({ skip: parsedRequest.startIndex, take: parsedRequest.endIndex, where: { user: { username: user.username } } });
  }

  /**
   * Returns the last year of net worth data
   */
  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.getNetWorth, "GET"))
  async getNetWorth(_request: RestBody, user: User) {
    // Calculate net worth from all accounts
    const accounts = await Account.find({ where: { user: { id: user.id } } });
    return accounts.reduce((acc, account) => acc + account.balance, 0);
  }
}
