import { DatabaseDecorators } from "@backend/database/decorators";
import { Account } from "@backend/model/account";
import { DatabaseBase } from "@backend/model/database.base";
import { Holding } from "@backend/model/holding";
import { isSameDay, subYears } from "date-fns";
import { ManyToOne, MoreThan } from "typeorm";

/** This class provides information for a historical stock data. */
@DatabaseDecorators.entity()
export class HoldingHistory extends DatabaseBase {
  /** The holding this history is associated to */
  @ManyToOne(() => Holding, (h) => h.id, { eager: true, onDelete: "CASCADE" })
  holding!: Holding;

  @DatabaseDecorators.column({ nullable: false })
  declare time: Date;

  @DatabaseDecorators.numericColumn({ nullable: false })
  declare costBasis: number;
  @DatabaseDecorators.numericColumn({ nullable: false })
  declare marketValue: number;
  @DatabaseDecorators.numericColumn({ nullable: false })
  declare purchasePrice: number;
  @DatabaseDecorators.numericColumn({ nullable: false })
  declare shares: number;

  /**
   * Grabs the history for all holdings related to the given account for the given time. Automatically
   *  handles only grabbing one relevant data point per day to make sure we don't have duplicate histories.
   */
  static async getHistoryForAccount(account: Account, years = 1) {
    const history = await HoldingHistory.findMostRecentInGroup({
      dateColumn: "time",
      partitionBy: ["holdingId" as any],
      joins: ["holding"],
      where: { time: MoreThan(subYears(new Date(), years)), holding: { account: { id: account.id } } },
    });
    // Add today's history
    if (!history.find((x) => isSameDay(x.time, new Date()))) history.push(...(await Holding.getForAccount(account)).map((x) => x.toAccountHistory()));
    return history;
  }
}
