import { Configuration } from "@backend/config/core";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { Injectable } from "@nestjs/common";
import { subDays } from "date-fns";
import { LessThan } from "typeorm";
import { BackgroundJob } from "./job-base";

/** This class defines a background job that executes to check things like stuck pending transactions */
@Injectable()
export class PendingTransactionJob extends BackgroundJob<any> {
  constructor() {
    super("transaction:pending", Configuration.transaction.struckTransactions.time, Configuration.transaction.struckTransactions.enabled, true);
  }

  protected async update() {
    this.logger.log("Checking for stuck pending transactions...");
    const oneWeekAgo = subDays(new Date(), Configuration.transaction.struckTransactions.days);
    const result = await Transaction.delete({
      pending: true,
      posted: LessThan(oneWeekAgo),
    });
    if ((result.affected ?? 0) > 0) this.logger.warn(`Removed ${result.affected} stuck pending transactions.`);
    else this.logger.log("No stuck pending transactions!");
  }
}
