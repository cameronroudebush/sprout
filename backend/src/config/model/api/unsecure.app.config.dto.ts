import { UnsecureOIDCConfig } from "@backend/auth/model/api/unsecure.oidc.config.dto";
import { Base } from "@backend/core/model/base";
import { Optional } from "@nestjs/common";

/** This class provides additional information to those who request but it is **note secured behind authentication requirements** */
export class UnsecureAppConfiguration extends Base {
  /** If this is the first time someone has connected to this interface */
  firstTimeSetupPosition: "welcome" | "complete";
  /** Version of the backend */
  version: string;

  /** The OIDC configuration if the server is instead setup to do that. */
  @Optional()
  oidcConfig?: UnsecureOIDCConfig;

  constructor(firstTimeSetupPosition: "welcome" | "complete" = "complete", version: string, oidcConfig?: UnsecureOIDCConfig) {
    super();
    this.firstTimeSetupPosition = firstTimeSetupPosition;
    this.version = version;
    this.oidcConfig = oidcConfig;
  }
}
