import { SimpleFINConfig } from "@backend/providers/simple-fin/config";
import { ZillowConfig } from "@backend/providers/zillow/config";
import { ConfigurationMetadata } from "../../config/model/configuration.metadata";

export class ProvidersConfig {
  @ConfigurationMetadata.assign({ comment: "How often to perform data queries for data from providers. Default is once a day at 8am." })
  updateTime: string = "0 8 * * *";

  @ConfigurationMetadata.assign({ comment: "SimpleFIN configuration: https://www.simplefin.org/" })
  simpleFIN = new SimpleFINConfig();

  @ConfigurationMetadata.assign({ comment: "Zillow configuration: https://www.zillow.com/" })
  zillow = new ZillowConfig();
}
