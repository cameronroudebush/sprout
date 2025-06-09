import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/model/database.base";

/** This model tracks background syncing progress. Tracks if we have ran into errors when a sync was ran. */
@DatabaseDecorators.entity()
export class Schedule extends DatabaseBase {
  /** When this was started */
  @DatabaseDecorators.column({ nullable: false })
  declare time: Date;

  @DatabaseDecorators.column({ nullable: false })
  declare status: "in-progress" | "complete" | "failed";

  @DatabaseDecorators.column({ nullable: true })
  declare failureReason: string;
}
