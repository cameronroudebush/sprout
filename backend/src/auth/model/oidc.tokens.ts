/** A model that allows us to track the tokens as they are created across Sprout. */
export class OIDCTokens {
  idToken: string;
  accessToken: string;
  refreshToken: string;

  /** Generated during mobile exchanges and required during those to prevent anyone from getting the exchange. */
  appChallenge?: string;

  constructor(idToken: string, accessToken: string, refreshToken: string, appChallenge?: string) {
    this.idToken = idToken;
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.appChallenge = appChallenge;
  }
}
