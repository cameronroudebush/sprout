import { PlaidInstitutionHandler } from "@backend/financeAPI/plaid/institution";
import { PlaidApi, Products } from "plaid";

/** This class handles acquiring tokens necessary for plaid data lookups */
export class PlaidTokenHandler {
  constructor(
    private client: PlaidApi,
    private institutionHandler: PlaidInstitutionHandler,
  ) {}

  async getPublicToken(initialProducts: Products[] = [Products.Transactions]) {
    // TODO: This is never going to work outside of sandbox
    const institutions = await this.institutionHandler.getInstitutions();
    return (await this.client.sandboxPublicTokenCreate({ institution_id: institutions[3]!.institution_id, initial_products: initialProducts })).data
      .public_token;
  }

  async getAccessToken(publicToken: string) {
    return (await this.client.itemPublicTokenExchange({ public_token: publicToken })).data.access_token;
  }
}
