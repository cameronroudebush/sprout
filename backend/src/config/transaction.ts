import { ConfigurationMetadata } from "@backend/config/configuration.metadata";

/** Contains transaction configuration options */
export class TransactionConfig {
  @ConfigurationMetadata.assign({ comment: "When to check for stuck transactions. This includes things like stuck pending." })
  stuckTransactionTime: string = "0 3 * * *";
}
