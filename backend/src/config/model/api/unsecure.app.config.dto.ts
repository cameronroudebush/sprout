import { AuthenticationConfig } from "@backend/auth/model/authentication.config";
import { Base } from "@backend/core/model/base";
import { ApiProperty } from "@nestjs/swagger";

/** Tracks demo credentials if the app is running demo mode */
export class DemoCredentials {
  @ApiProperty()
  username!: string;

  @ApiProperty()
  password!: string;
}

/** This class provides additional information to those who request but it is **note secured behind authentication requirements** */
export class UnsecureAppConfiguration extends Base {
  /** Version of the backend */
  version: string;
  @ApiProperty({
    enum: ["oidc", "local"],
  })
  authMode: AuthenticationConfig["type"];
  allowUserCreation: boolean;

  /** Present only when the application is running in an auto-authenticating demo environment */
  @ApiProperty({ type: DemoCredentials, required: false })
  demoMode?: DemoCredentials;

  constructor(version: string, authMode: AuthenticationConfig["type"], allowUserCreation: boolean, demoModeCredentials?: DemoCredentials) {
    super();
    this.version = version;
    this.authMode = authMode;
    this.allowUserCreation = allowUserCreation;
    this.demoMode = demoModeCredentials;
  }
}
