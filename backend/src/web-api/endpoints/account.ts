import { Account } from "@backend/model/account";
import { RestEndpoints } from "@backend/model/api/endpoint";
import { RestBody } from "@backend/model/api/rest.request";
import { Holding } from "@backend/model/holding";
import { Institution } from "@backend/model/institution";
import { Transaction } from "@backend/model/transaction";
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

  /** Links the provider accounts to the given user */
  @RestMetadata.register(new RestMetadata(RestEndpoints.account.link, "POST"))
  async linkProviderAccounts(data: RestBody<Array<Account>>, user: User) {
    const accountsToLink = data.payload;
    // We need to grab all the provider accounts again because we want to make sure we have correct data
    const providerAccounts = await Providers.getCurrentProvider().get(user, true);
    // Add these new accounts to the database
    const addedAccounts: Account[] = [];
    for (const account of accountsToLink) {
      const matchingAccount = providerAccounts.find((z) => z.account.name === account.name);
      if (matchingAccount) {
        matchingAccount.account.user = user;
        // Try to find a matching institution first if it exists
        const matchingInstitution = await Institution.findOne({ where: { id: matchingAccount.account.institution.id } });
        if (matchingInstitution) matchingAccount.account.institution = matchingInstitution;
        await matchingAccount.account.insert();
        // Insert matching transactions
        matchingAccount.transactions.map((x) => (x.account = matchingAccount.account));
        await Transaction.insertMany(matchingAccount.transactions);
        // Insert holdings
        matchingAccount.holdings.map((x) => (x.account = matchingAccount.account));
        await Holding.insertMany(matchingAccount.holdings);
        addedAccounts.push(matchingAccount.account);
      }
    }
    return addedAccounts;
  }
}
