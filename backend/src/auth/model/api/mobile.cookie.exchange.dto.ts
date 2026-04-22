import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString } from "class-validator";

/** A DTO used to track mobile token exchanges to set them into cookies. */
export class MobileTokenExchangeDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  code: string;

  @ApiProperty({ description: "Specifies the app verifier that is hashed" })
  @IsString()
  @IsNotEmpty()
  appVerifier: string;

  constructor(code: string, appVerifier: string) {
    this.code = code;
    this.appVerifier = appVerifier;
  }
}
