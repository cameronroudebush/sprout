import { Transaction } from "@backend/model/transaction";
import { RestBody, RestEndpoints, TransactionRequest, User } from "@common";
import { RestMetadata } from "../metadata";

export class TransactionAPI {
  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.get, "POST"))
  async getTransactions(request: RestBody, user: User) {
    const parsedRequest = TransactionRequest.fromPlain(request.payload);
    // TODO: What to do with the request?
    console.log(parsedRequest);
    return await Transaction.find({ where: { user: { username: user.username } } });
  }

  /**
   * Returns the last year of net worth data
   */
  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.getNetWorth, "GET"))
  async getNetWorth(request: RestBody) {
    const parsedRequest = TransactionRequest.fromPlain(request.payload);
    console.log(parsedRequest);
    return 0;
  }
}
