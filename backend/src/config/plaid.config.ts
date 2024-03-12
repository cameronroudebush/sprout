import { Configuration, PlaidEnvironments } from "plaid";
import { ConfigurationMetadata } from "./configuration.metadata";

/** Configuration options directly specific to plaid api */
export class PlaidConfiguration {
  /** The Client ID for your login. DO NOT SHARE THIS. */
  @ConfigurationMetadata.assign({})
  clientID: string = "PLEASE_REPLACE";

  /** The Secret key ID for your plaid login. DO NOT SHARE THIS. */
  @ConfigurationMetadata.assign({})
  secret: string = "PLEASE_REPLACE";

  get config() {
    return new Configuration({
      basePath: PlaidEnvironments["sandbox"],
      baseOptions: {
        headers: {
          // TODO: These are very secret!
          "PLAID-CLIENT-ID": this.clientID, //"65ee47e732a829001cdf17cd",
          "PLAID-SECRET": this.secret, //"c11eeaa2759e3b0d153c59eaab1b61",
        },
      },
    });
  }
}
