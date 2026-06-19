import { PlaidConfig } from "@backend/providers/plaid/config";
import { SimpleFINConfig } from "@backend/providers/simple-fin/config";
import { ZillowConfig } from "@backend/providers/zillow/config";
import { ConfigurationMetadata } from "../../config/model/configuration.metadata";

export class SyncNotifications {
  @ConfigurationMetadata.assign({
    comment: "If we should send notifications for syncs at a routine interval.",
    externalControlDisabled: true,
  })
  enabled: boolean = true;

  @ConfigurationMetadata.assign({
    comment: "How often we want to check for to send updated notifications to users for new data.",
    externalControlDisabled: true,
  })
  time: string = "*/15 * * * *";
}

export class ProvidersConfig {
  @ConfigurationMetadata.assign({ comment: " Controls sending sync notifications for users", externalControlDisabled: true })
  syncNotifications = new SyncNotifications();

  @ConfigurationMetadata.assign({ comment: "SimpleFIN configuration: https://www.simplefin.org/" })
  simpleFIN = new SimpleFINConfig();

  @ConfigurationMetadata.assign({ comment: "Zillow configuration: https://www.zillow.com/" })
  zillow = new ZillowConfig();

  @ConfigurationMetadata.assign({ comment: "Plaid configuration: https://plaid.com/" })
  plaid = new PlaidConfig();
}
