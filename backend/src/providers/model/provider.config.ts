import { SimpleFINConfig } from "@backend/providers/simple-fin/config";
import { ZillowConfig } from "@backend/providers/zillow/config";
import { ConfigurationMetadata } from "../../config/model/configuration.metadata";

export class ProvidersConfig {
  @ConfigurationMetadata.assign({ comment: "SimpleFIN configuration: https://www.simplefin.org/" })
  simpleFIN = new SimpleFINConfig();

  @ConfigurationMetadata.assign({ comment: "Zillow configuration: https://www.zillow.com/" })
  zillow = new ZillowConfig();
}
