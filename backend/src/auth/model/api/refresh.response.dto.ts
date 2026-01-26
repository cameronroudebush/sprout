import { ApiProperty } from "@nestjs/swagger";

/** Contains what properties we'll see in a response of OIDC token refresh */
export class RefreshResponseDTO {
  @ApiProperty()
  idToken: string;
  @ApiProperty()
  accessToken: string;
  @ApiProperty({ required: false })
  refreshToken?: string;

  constructor(idToken: string, accessToken: string, refreshToken?: string) {
    this.idToken = idToken;
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }
}
