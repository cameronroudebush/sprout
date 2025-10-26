import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { ChartRange } from "@backend/user/model/chart.range.model";
import { ApiProperty } from "@nestjs/swagger";
import { IsBoolean } from "class-validator";

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
  @ApiProperty({ enum: ChartRange, enumName: "ChartRangeEnum" })
  netWorthRange: ChartRange;

  constructor(privateMode: boolean, netWorthRange: UserConfig["netWorthRange"]) {
    super();
    this.privateMode = privateMode;
    this.netWorthRange = netWorthRange;
  }
}
