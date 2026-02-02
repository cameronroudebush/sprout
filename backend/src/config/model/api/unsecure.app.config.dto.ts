import { AuthenticationConfig } from "@backend/auth/model/authentication.config";
import { Base } from "@backend/core/model/base";
import { ApiProperty } from "@nestjs/swagger";

/** This class provides additional information to those who request but it is **note secured behind authentication requirements** */
export class UnsecureAppConfiguration extends Base {
  /** Version of the backend */
  version: string;
  @ApiProperty({
    enum: ["oidc", "local"],
  })
  authMode: AuthenticationConfig["type"];
  allowUserCreation: boolean;

  constructor(version: string, authMode: AuthenticationConfig["type"], allowUserCreation: boolean) {
    super();
    this.version = version;
    this.authMode = authMode;
    this.allowUserCreation = allowUserCreation;
  }
}
