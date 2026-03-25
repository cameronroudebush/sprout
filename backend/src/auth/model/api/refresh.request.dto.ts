import { ApiProperty } from "@nestjs/swagger";
import { IsString } from "class-validator";

/** Contains what properties we'll see in a request of OIDC token refresh */
export class RefreshRequestDTO {
  @ApiProperty({ description: "The current refresh token" })
  @IsString()
  refreshToken: string;

  constructor(refreshToken: string) {
    this.refreshToken = refreshToken;
  }
}
