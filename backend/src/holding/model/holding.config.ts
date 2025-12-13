import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";

/** Contains holding configuration options */
export class HoldingConfig {
  @ConfigurationMetadata.assign({
    comment:
      "If we should clean-up holdings from the database as we no longer find them on the provider. Warning, this will remove all history for these holdings if set to true.",
  })
  cleanupRemovedHoldings: boolean = false;
}
