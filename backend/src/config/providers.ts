import { SimpleFINConfig } from "@backend/providers/simple-fin/config";
import { ConfigurationMetadata } from "./configuration.metadata";

export class ProvidersConfig {
  @ConfigurationMetadata.assign({ comment: "How often to perform data queries for data from providers. Default is once a day at 7am." })
  updateTime: string = "0 7 * * *";

  @ConfigurationMetadata.assign({ comment: "SimpleFIN configuration: https://www.simplefin.org/" })
  simpleFIN = new SimpleFINConfig();
}
