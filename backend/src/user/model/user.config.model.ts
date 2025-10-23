import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { IsBoolean, IsEnum } from "class-validator";

const NetWorthRangeValues = ["oneDay", "sevenDays", "oneMonth", "threeMonths", "sixMonths", "oneYear", "allTime"];

/**
 * This class defines user configuration options per user
 */
@DatabaseDecorators.entity()
export class UserConfig extends DatabaseBase {
  /** If we should hide balances on the users display */
  @DatabaseDecorators.column({ nullable: false, default: false })
  @IsBoolean()
  privateMode: boolean;

  /** The net worth range to display by default */
  @DatabaseDecorators.column({ nullable: false, default: "oneDay", type: "varchar" })
  @IsEnum(NetWorthRangeValues, {
    message: `subType must be one of the following values: ${NetWorthRangeValues.join(", ")}`,
  })
  netWorthRange: string;

  constructor(privateMode: boolean, netWorthRange: UserConfig["netWorthRange"]) {
    super();
    this.privateMode = privateMode;
    this.netWorthRange = netWorthRange;
  }
}
