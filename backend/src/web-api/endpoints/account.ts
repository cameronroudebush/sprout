import { Account } from "@backend/model/account";
import { RestEndpoints } from "@backend/model/api/endpoint";
import { LinkProvider } from "@backend/model/api/link_provider";
import { RestBody } from "@backend/model/api/rest.request";
import { Base } from "@backend/model/base";
import { Holding } from "@backend/model/holding";
import { Institution } from "@backend/model/institution";
import { Transaction } from "@backend/model/transaction";
import { TransactionRule } from "@backend/model/transaction.rule";
import { User } from "@backend/model/user";
import { ProviderConfig } from "@backend/providers/base/config";
import { Providers } from "../../providers";
import { RestMetadata } from "../metadata";
import { SSEAPI } from "./sse";

export class AccountAPI {
  @RestMetadata.register(new RestMetadata(RestEndpoints.account.getAll, "GET"))
  async getAccounts(_data: RestBody, user: User) {
    return await Account.find({ where: { user: user } });
  }

  @RestMetadata.register(new RestMetadata(RestEndpoints.account.delete, "POST"))
  async deleteAccount(data: RestBody<Account>, user: User) {
    await Account.deleteById(data.payload.id);
    SSEAPI.sendToSSEUser.next({ payload: Base.fromPlain({}), queue: "sync", user });
    return data.payload.id;
  }

  /** Returns accounts for the given provider that are not already synced */
  @RestMetadata.register(new RestMetadata(RestEndpoints.account.getAllFromProvider, "GET"))
  async getProviderAccounts(data: RestBody<ProviderConfig>, user: User) {
    const matchingProvider = Providers.getAll().find((x) => x.config.name === data.payload.name);
    if (matchingProvider == null) throw new Error(`Failed to locate matching provider for ${data.payload.name}`);
    const existingAccounts = await Account.find({ where: { user: user } });
    const providerAccounts = (await matchingProvider.get(user, true)).map((x) => x.account);
    return providerAccounts.filter((providerAccount) => !existingAccounts.some((existingAccount) => existingAccount.id === providerAccount.id));
  }

  /** Links the provider accounts to the given user */
  @RestMetadata.register(new RestMetadata(RestEndpoints.account.link, "POST"))
  async linkProviderAccounts(data: RestBody<LinkProvider>, user: User) {
    const accountsToLink = data.payload.accounts;
    const providers = Providers.getAll();
    const providerMatch = providers.find((x) => x.config.name === data.payload.provider.name);
    if (providerMatch == null) throw new Error("Failed to locate matching provider");
    // We need to grab all the provider accounts again because we want to make sure we have correct data
    const providerAccounts = await providerMatch.get(user, true);
    // Add these new accounts to the database
    const addedAccounts: Account[] = [];
    for (const account of accountsToLink) {
      const matchingAccount = providerAccounts.find((z) => z.account.name === account.name);
      if (matchingAccount) {
        matchingAccount.account.user = user;
        // Try to find a matching institution first if it exists
        const matchingInstitution = await Institution.findOne({ where: { id: matchingAccount.account.institution.id } });
        if (matchingInstitution) matchingAccount.account.institution = matchingInstitution;
        matchingAccount.account.subType = account.subType;
        if (account.subType != null) Account.validateSubType(account.subType);
        await matchingAccount.account.insert();
        // Insert matching transactions
        matchingAccount.transactions.map((x) => (x.account = matchingAccount.account));
        await Transaction.insertMany(matchingAccount.transactions);
        // Run transaction rules
        await TransactionRule.applyRulesToTransactions(user, undefined, true);
        // Insert holdings
        matchingAccount.holdings.map((x) => (x.account = matchingAccount.account));
        await Holding.insertMany(matchingAccount.holdings);
        addedAccounts.push(matchingAccount.account);
      }
    }
    SSEAPI.sendToSSEUser.next({ payload: Base.fromPlain({}), queue: "sync", user });
    return addedAccounts;
  }

  /** Allows editing certain account metadata */
  @RestMetadata.register(new RestMetadata(RestEndpoints.account.edit, "POST"))
  async edit(data: RestBody<Account>, user: User) {
    const matchingAccount = await Account.findOne({ where: { id: data.payload.id, user: { id: user.id } } });
    if (matchingAccount == null) throw new Error("Failed to locate a matching account to update");
    // Update only the allowed fields
    matchingAccount.name = data.payload.name ?? matchingAccount.name;
    matchingAccount.subType = data.payload.subType;
    return await matchingAccount.update();
  }
}
