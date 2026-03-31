import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsNumber, IsString } from "class-validator";

/** A DTO that contains the results from a successful lookup. */
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

  constructor(zpid: string, zestimate: number, rentZestimate: number) {
    this.zpid = zpid;
    this.zestimate = zestimate;
    this.rentZestimate = rentZestimate;
  }
}
