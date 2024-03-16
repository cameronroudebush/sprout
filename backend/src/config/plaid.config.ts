import { Configuration, PlaidEnvironments } from "plaid";
import { ConfigurationMetadata } from "./configuration.metadata";

/** Configuration options directly specific to plaid api */
export class PlaidConfiguration {
  /** The Client ID for your login. DO NOT SHARE THIS. */
  @ConfigurationMetadata.assign({})
  clientId: string = "PLEASE_REPLACE";

  /** The Secret key ID for your plaid login. DO NOT SHARE THIS. */
  @ConfigurationMetadata.assign({})
  secret: string = "PLEASE_REPLACE";

  get config() {
    return new Configuration({
      basePath: PlaidEnvironments["sandbox"],
      baseOptions: {
        headers: {
          "PLAID-CLIENT-ID": this.clientId,
          "PLAID-SECRET": this.secret,
        },
      },
    });
  }
}
