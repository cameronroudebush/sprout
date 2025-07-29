import { Configuration } from "@backend/config/core";
import { Logger } from "@backend/logger";
import { Transaction } from "@backend/model/transaction";
import { subDays } from "date-fns";
import { LessThan } from "typeorm";
import { BackgroundJob } from "./base";

/** This class defines a background job that executes to check things like stuck pending transactions */
export class PendingTransactionJob extends BackgroundJob<any> {
  constructor() {
    super("pending-transaction", Configuration.transaction.stuckTransactionTime);
  }

  override async start() {
    // Always perform an initial pending check on startup
    return super.start(true);
  }

  protected async update() {
    Logger.info("Checking for stuck pending transactions...", this.logConfig);
    const oneWeekAgo = subDays(new Date(), 7);
    const stuckTransactions = await Transaction.find({
      where: {
        pending: true,
        posted: LessThan(oneWeekAgo),
      },
    });
    if (stuckTransactions.length > 0) {
      Logger.warn(`Found ${stuckTransactions.length} stuck pending transactions. Deleting them.`, this.logConfig);
      await Transaction.deleteMany(stuckTransactions.map((x) => x.id));
    } else Logger.success("No stuck pending transactions!");
  }
}
