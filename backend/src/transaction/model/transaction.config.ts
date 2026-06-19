import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";

class StuckTransactionConfig {
  @ConfigurationMetadata.assign({
    comment: "If we should check for stuck transactions.",
    restrictedValues: [true, false],
  })
  enabled = true;

  @ConfigurationMetadata.assign({
    comment: "When to check for stuck pending transactions that didn't get cleaned up by the provider. Should be a cron expression.",
    externalControlDisabled: true,
  })
  time: string = "0 */6 * * *";

  @ConfigurationMetadata.assign({ comment: "How many days old a transaction has to be stuck for it to be auto deleted." })
  days: number = 7;
}

/** Contains transaction configuration options */
export class TransactionConfig {
  @ConfigurationMetadata.assign({ comment: "Configuration for when and how to check for stuck transactions (pending)." })
  stuckTransactions = new StuckTransactionConfig();

  @ConfigurationMetadata.assign({ comment: "How many occurrences of similar transactions counts as a subscription." })
  subscriptionCount: number = 3;
}
