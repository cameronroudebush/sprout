import { RestBody, RestEndpoints, Transaction, TransactionRequest } from "@common";
import { RestMetadata } from "../metadata";

// TODO: Remove
const fakeData = Array.from({ length: 10 }).map(() =>
  Transaction.fromPlain({ account: "foobar", date: new Date(), amount: Math.floor(Math.random() * (1000 - 100) + 100) / 100 }),
);

export class TransactionAPI {
  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.get, "POST", false))
  async login(request: RestBody) {
    const parsedRequest = TransactionRequest.fromPlain(request.payload);
    console.log(parsedRequest);
    return fakeData;
  }
}
