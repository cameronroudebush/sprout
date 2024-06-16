import { Account, RestEndpoints } from "@common";
import { RestMetadata } from "../metadata";

// TODO: Remove
const fakeData = Array.from({ length: 10 }).map((_, i) => Account.fromPlain({ id: i, name: "foobar " + i }));

export class AccountAPI {
  @RestMetadata.register(new RestMetadata(RestEndpoints.account.get, "GET"))
  async getAccounts() {
    return fakeData;
  }
}
