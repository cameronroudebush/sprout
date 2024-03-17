import { Configuration, CountryCode, PlaidEnvironments } from "plaid";
import { ConfigurationMetadata } from "./configuration.metadata";

/** Configuration options directly specific to plaid api */
export class PlaidConfiguration {
  @ConfigurationMetadata.assign({ comment: "The Client ID for your login. DO NOT SHARE THIS." })
  clientId: string = "PLEASE_REPLACE";

  @ConfigurationMetadata.assign({ comment: "The Secret key ID for your plaid login. DO NOT SHARE THIS." })
  secret: string = "PLEASE_REPLACE";

  @ConfigurationMetadata.assign({ comment: "The Secret key ID for your plaid login. DO NOT SHARE THIS.", restrictedValues: ["sandbox"] })
  environment: string = "sandbox";

  get supportedCountryCodes() {
    return [CountryCode.Us];
  }

  get config() {
    return new Configuration({
      basePath: PlaidEnvironments[this.environment],
      baseOptions: {
        headers: {
          "PLAID-CLIENT-ID": this.clientId,
          "PLAID-SECRET": this.secret,
        },
      },
    });
  }
}
