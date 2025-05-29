import { ConfigurationMetadata } from "@backend/config/configuration.metadata";

/** The configuration for the SimpleFIN provider */
export class SimpleFINConfig {
  @ConfigurationMetadata.assign({
    comment: [
      "This access token is acquired from SimpleFIN that allows us to authenticate and grab your data.",
      "You'll need to go to this link to get one configured: ",
      "https://beta-bridge.simplefin.org/info/developers",
    ],
  })
  accessToken?: string;
}
