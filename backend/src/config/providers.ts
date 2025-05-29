import { SimpleFINConfig } from "@backend/providers/simple-fin/config";
import { ConfigurationMetadata } from "./configuration.metadata";

export class ProvidersConfig {
  @ConfigurationMetadata.assign({ comment: "SimpleFIN configuration: https://www.simplefin.org/" })
  simpleFIN = new SimpleFINConfig();
}
