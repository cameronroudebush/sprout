import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString } from "class-validator";

/** A DTO used to track mobile token exchanges to set them into cookies. */
export class MobileTokenExchangeDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  idToken: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  accessToken: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  refreshToken: string;

  constructor(idToken: string, accessToken: string, refreshToken: string) {
    this.idToken = idToken;
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }
}
