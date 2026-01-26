import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";

/** Contains transaction configuration options */
export class TransactionConfig {
  @ConfigurationMetadata.assign({ comment: "When to check for stuck pending transactions that didn't get cleaned up by the provider." })
  stuckTransactionTime: string = "0 */6 * * *";

  @ConfigurationMetadata.assign({ comment: "How many days old a transaction has to be stuck for it to be auto deleted." })
  stuckTransactionDays: number = 7;

  @ConfigurationMetadata.assign({ comment: "How many occurrences of similar transactions counts as a subscription." })
  subscriptionCount: number = 3;
}
