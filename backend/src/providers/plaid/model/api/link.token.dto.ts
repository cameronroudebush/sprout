import { Trim } from "@backend/core/decorator/trim";
import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString } from "class-validator";

/** A DTO that contains link information for plaid */
export class PlaidLinkTokenDTO {
  @ApiProperty({})
  @IsString()
  @IsNotEmpty()
  @Trim()
  linkToken: string;

  constructor(idToken: string) {
    this.linkToken = idToken;
  }
}
