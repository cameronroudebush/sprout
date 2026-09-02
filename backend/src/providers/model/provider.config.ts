import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";
import { CoinbaseConfig } from "@backend/providers/coinbase/model/config";
import { PlaidConfig } from "@backend/providers/plaid/config";
import { SimpleFINConfig } from "@backend/providers/simple-fin/config";
import { SnapTradeConfig } from "@backend/providers/snap-trade/model/config";
import { ZillowConfig } from "@backend/providers/zillow/config";

export class SyncNotifications {
  @ConfigurationMetadata.assign({
    comment: "If we should send notifications for syncs at a routine interval.",
    externalControlDisabled: true,
  })
  enabled: boolean = true;
}

export class ProvidersConfig {
  @ConfigurationMetadata.assign({ comment: " Controls sending sync notifications for users", externalControlDisabled: true })
  syncNotifications = new SyncNotifications();

  @ConfigurationMetadata.assign({
    comment: "How often we want to handle the post sync job so we can send notifications or generate data with the freshest finance data handled.",
    externalControlDisabled: true,
  })
  postSyncTime: string = "*/15 * * * *";

  @ConfigurationMetadata.assign({
    comment: "How many days to look back for transactional data. Not supported by every provider.",
    externalControlDisabled: true,
  })
  lookBackDays: number = 14;

  @ConfigurationMetadata.assign({ comment: "SimpleFIN configuration: https://www.simplefin.org/" })
  simpleFIN = new SimpleFINConfig();

  @ConfigurationMetadata.assign({ comment: "Zillow configuration: https://www.zillow.com/" })
  zillow = new ZillowConfig();

  @ConfigurationMetadata.assign({ comment: "Plaid configuration: https://plaid.com/" })
  plaid = new PlaidConfig();

  @ConfigurationMetadata.assign({ comment: "SnapTrade configuration: https://snaptrade.com/" })
  snapTrade = new SnapTradeConfig();

  @ConfigurationMetadata.assign({ comment: "SnapTrade configuration: https://coinbase.com/" })
  coinbase = new CoinbaseConfig();
}
