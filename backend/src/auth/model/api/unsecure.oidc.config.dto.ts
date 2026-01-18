/** A class that represents an unsecured OIDC configuration to tell the frontend how to login. */
export class UnsecureOIDCConfig {
  issuer: string;
  clientId: string;
  scopes: string[];

  constructor(issuer: string, clientId: string, scopes: string[]) {
    this.issuer = issuer;
    this.clientId = clientId;
    this.scopes = scopes;
  }
}
