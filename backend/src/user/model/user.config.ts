import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";

/**
 * This class defines user configuration options per user
 */
@DatabaseDecorators.entity()
export class UserConfig extends DatabaseBase {
  /** If we should hide balances on the users display */
  @DatabaseDecorators.column({ nullable: false, default: false })
  privateMode: boolean;

  /** The net worth range to display by default */
  @DatabaseDecorators.column({ nullable: false, default: "oneDay" })
  netWorthRange: string;

  constructor(privateMode: boolean, netWorthRange: string) {
    super();
    this.privateMode = privateMode;
    this.netWorthRange = netWorthRange;
  }
}
