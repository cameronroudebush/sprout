import { Account } from "@backend/model/account";
import { RestEndpoints } from "@backend/model/api/endpoint";
import { RestBody } from "@backend/model/api/rest.request";
import { User } from "@backend/model/user";
import { RestMetadata } from "../metadata";

export class AccountAPI {
  @RestMetadata.register(new RestMetadata(RestEndpoints.account.getAll, "GET"))
  async getAccounts(_data: RestBody, user: User) {
    return await Account.find({ where: { user: user } });
  }
}
