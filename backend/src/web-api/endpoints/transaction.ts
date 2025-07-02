import { Account } from "@backend/model/account";
import { RestEndpoints } from "@backend/model/api/endpoint";
import { RestBody } from "@backend/model/api/rest.request";
import { TransactionRequest } from "@backend/model/api/transaction";
import { Transaction } from "@backend/model/transaction";
import { User } from "@backend/model/user";
import { RestMetadata } from "../metadata";

export class TransactionAPI {
  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.get, "POST"))
  async getTransactions(request: RestBody, user: User) {
    const parsedRequest = TransactionRequest.fromPlain(request.payload);
    return await Transaction.find({ skip: parsedRequest.startIndex, take: parsedRequest.endIndex, where: { account: { user: { username: user.username } } } });
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
