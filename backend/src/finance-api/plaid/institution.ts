import { PlaidConfiguration } from "@backend/config/plaid.config";
import { PlaidApi } from "plaid";

/** Handles looking up information about Plaid institutions */
export class PlaidInstitutionHandler {
  constructor(
    private client: PlaidApi,
    private configuration: PlaidConfiguration,
  ) {}

  /**
   * Returns supported institution list
   * @param count How many to get
   * @param offset What "page" of the institutions to get based on count
   */
  async getInstitutions(count = 10, offset = 0) {
    return (await this.client.institutionsGet({ count, offset, country_codes: this.configuration.supportedCountryCodes })).data.institutions;
  }
}
