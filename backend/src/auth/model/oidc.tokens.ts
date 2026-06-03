import { Base } from "@backend/core/model/base";

/** A model that allows us to track the tokens as they are created across Sprout. */
export class OIDCTokens extends Base {
  idToken: string;
  accessToken: string;
  refreshToken: string;

  /** Generated during mobile exchanges and required during those to prevent anyone from getting the exchange. */
  appChallenge?: string;

  constructor(idToken: string, accessToken: string, refreshToken: string, appChallenge?: string) {
    super();
    this.idToken = idToken;
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.appChallenge = appChallenge;
  }
}
