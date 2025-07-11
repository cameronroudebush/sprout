import { Account } from "@backend/model/account";
import { RestEndpoints } from "@backend/model/api/endpoint";
import { RestBody } from "@backend/model/api/rest.request";
import { User } from "@backend/model/user";
import { Providers } from "../../providers";
import { RestMetadata } from "../metadata";

export class AccountAPI {
  @RestMetadata.register(new RestMetadata(RestEndpoints.account.getAll, "GET"))
  async getAccounts(_data: RestBody, user: User) {
    return await Account.find({ where: { user: user } });
  }

  /** Returns accounts the provider knows about to be added to sprout */
  @RestMetadata.register(new RestMetadata(RestEndpoints.account.getAllFromProvider, "GET"))
  async getProviderAccounts(_data: RestBody, user: User) {
    const providerAccounts = (await Providers.getCurrentProvider().get(user, true)).map((x) => x.account);
    const existingAccounts = await Account.find({ where: { user: user } });
    return providerAccounts.filter((providerAccount) => !existingAccounts.some((existingAccount) => existingAccount.id === providerAccount.id));
  }
}
