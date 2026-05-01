import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { ApiHideProperty, ApiProperty } from "@nestjs/swagger";
import { Exclude } from "class-transformer";
import { IsNotEmpty, IsNumber, IsString } from "class-validator";

/** A DTO that contains the results from a successful lookup. */
@CurrencyHelper.ExposeCurrencyFields<ZillowPropertyResultDto>("zestimate", "currency")
@CurrencyHelper.ExposeCurrencyFields<ZillowPropertyResultDto>("rentZestimate", "currency")
export class ZillowPropertyResultDto {
  @ApiProperty({ example: "123 Main St" })
  @IsNumber()
  zestimate: number;

  @ApiProperty({ example: "Seattle" })
  @IsNumber()
  rentZestimate: number;

  @ApiProperty({})
  @IsString()
  @IsNotEmpty()
  zpid: string;

  @ApiHideProperty()
  @Exclude({ toPlainOnly: true })
  currency: string;

  constructor(zpid: string, zestimate: number, rentZestimate: number, currency: string) {
    this.zpid = zpid;
    this.zestimate = zestimate;
    this.rentZestimate = rentZestimate;
    this.currency = currency;
  }
}
