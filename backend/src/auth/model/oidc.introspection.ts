import { Configuration } from "@backend/config/core";
import { Base } from "@backend/core/model/base";
import { UnauthorizedException } from "@nestjs/common";
import { Expose } from "class-transformer";

/** Used to store the introspection result from the OIDC providers */
export class OIDCIntrospectionResult extends Base {
  active!: boolean;
  @Expose({ name: "client_id" })
  clientId!: string;
  /** Time in seconds since linux epoch that this expires */
  @Expose({ name: "exp" })
  expiresAt!: number;
  /** Time in seconds since linux epoch of when this was issued */
  @Expose({ name: "iat" })
  issuedAt!: number;
  scope!: string;
  @Expose({ name: "sub" })
  subject!: string;
  username!: string;

  /** Returns if this is expired */
  get isExpired() {
    return Date.now() / 1000 >= this.expiresAt;
  }

  /** Checks if the current introspection result was issued for us. If not, throws an error. */
  checkIssuedState() {
    const config = Configuration.server.auth.oidc;
    if (this.clientId !== config.clientId) throw new UnauthorizedException("Invalid token client.");
  }
}

/** Extension upon {@link OIDCIntrospectionResult} but adds the fields that the Id token will contain. */
export class OIDCIDTokenIntrospectionResult extends OIDCIntrospectionResult {
  @Expose({ name: "iss" })
  issuer!: string;
  @Expose({ name: "aud" })
  audience!: Array<string>;
  @Expose({ name: "azp" })
  authorizedParty!: string;

  /** Checks if the current introspection result was issued for us. If not, throws an error. */
  override checkIssuedState() {
    const config = Configuration.server.auth.oidc;
    if (this.issuer !== config.issuer) throw new UnauthorizedException("Invalid token issuer.");
    if (this.authorizedParty !== config.clientId) throw new UnauthorizedException("Invalid token audience.");
  }
}
