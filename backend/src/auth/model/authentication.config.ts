import { UnsecureOIDCConfig } from "@backend/auth/model/api/unsecure.oidc.config.dto";
import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";
import { v4 } from "uuid";

/** This class represents the configuration for OIDC */
class OIDCConfig {
  @ConfigurationMetadata.assign({ comment: "The issuer URL for who is issuing the JWT's for this OIDC. Do not include trailing slashes." })
  issuer = "";

  @ConfigurationMetadata.assign({ comment: "The client ID of your OIDC configuration so we can verify the audience." })
  clientId = "";

  @ConfigurationMetadata.assign({ comment: "The scopes we use for our information.", externalControlDisabled: true })
  scopes = ["openid", "profile", "email", "offline_access"];

  /** Validates the config is usable */
  validate() {
    if (!this.issuer) throw new Error("Issuer URL is required for OIDC usage.");
    if (!this.clientId) throw new Error("Client ID is required for OIDC usage.");
  }

  /** Returns a version that the frontend can track */
  toUnsecure() {
    return new UnsecureOIDCConfig(this.issuer, this.clientId, this.scopes);
  }
}

/** This class represents configuration for the local authentication strategy */
class LocalConfig {
  @ConfigurationMetadata.assign({ comment: "How long JWT's should stay valid for users." })
  jwtExpirationTime = "30m";
}

/** Configuration class for controlling how authentication works in this app */
export class AuthenticationConfig {
  /** A secret key that can be used to create JWT's and other relevant info for this app. **This will be regenerated during every restart!** */
  readonly secretKey = process.env["SECRET_KEY"]! ?? v4();

  @ConfigurationMetadata.assign({
    comment: [
      "The type of authentication strategy we want to use.",
      "local: Uses a local JWT authentication strategy where we sign JWT's with the backend. Only supports one user! Uses a randomly generated secret every startup.",
      "oidc: Uses the configured OIDC authentication to use a remote provider for validation. This will support multiple users.",
    ],
    restrictedValues: ["local", "oidc"],
  })
  type: "oidc" | "local" = "local";

  @ConfigurationMetadata.assign({ comment: "Configuration OIDC authentication capability." })
  oidc = new OIDCConfig();

  @ConfigurationMetadata.assign({ comment: "Configuration local authentication capability." })
  local = new LocalConfig();
}
