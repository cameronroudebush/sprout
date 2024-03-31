import { Configuration } from "@backend/config/core";
import { User as CommonUser } from "@common";
import jwt from "jsonwebtoken";

/** JWT object content that will be included */
type JWTContent = { username: string };

export class User extends CommonUser {
  /** Returns a fresh JWT for the current user */
  get JWT() {
    return jwt.sign({ username: this.username } as JWTContent, Configuration.server.secretKey, { expiresIn: Configuration.server.jwtExpirationTime });
  }

  /** Verifies the given JWT. Throws an error if it is not valid */
  static verifyJWT(jwtString?: string) {
    if (!jwtString) throw new Error("Invalid JWT");
    return jwt.verify(jwtString, Configuration.server.secretKey);
  }
}
