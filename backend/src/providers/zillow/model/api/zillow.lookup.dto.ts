import { Trim } from "@backend/core/decorator/trim";
import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsNumber, IsString } from "class-validator";

/** A DTO that contains all required info for lookup */
export class ZillowPropertyDTO {
  @ApiProperty({ example: "123 Main St" })
  @IsString()
  @IsNotEmpty()
  @Trim()
  address: string;

  @ApiProperty({ example: "Seattle" })
  @IsString()
  @IsNotEmpty()
  @Trim()
  city: string;

  @ApiProperty({ example: "WA" })
  @IsString()
  @IsNotEmpty()
  @Trim()
  state: string;

  @ApiProperty({ example: 98101 })
  @IsNumber()
  zip: number;

  constructor(address: string, city: string, state: string, zip: number) {
    this.address = address;
    this.city = city;
    this.state = state;
    this.zip = zip;
  }
}
