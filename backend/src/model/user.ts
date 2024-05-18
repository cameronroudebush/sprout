import { Configuration } from "@backend/config/core";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/model/database.base";
import { User as CommonUser } from "@common";
import bcrypt from "bcrypt";
import { Exclude } from "class-transformer";
import jwt from "jsonwebtoken";
import { Mixin } from "ts-mixer";

/** JWT object content that will be included */
type JWTContent = { username: string };

@DatabaseDecorators.entity()
export class User extends Mixin(CommonUser, DatabaseBase) {
  @DatabaseDecorators.column()
  declare firstName: string;

  @DatabaseDecorators.column()
  declare lastName: string;

  @DatabaseDecorators.column()
  declare username: string;

  @DatabaseDecorators.column()
  declare admin: boolean;

  /** Hashed password in the database to compare against */
  @DatabaseDecorators.column()
  @Exclude({ toClassOnly: true })
  declare password: string;

  /** Given a password, hashes it and returns it */
  static hashPassword(pass: string, saltRounds = 10) {
    return bcrypt.hashSync(pass, saltRounds);
  }

  /** Given a password to verify, compares our hashed password from {@link password} to the given one */
  verifyPassword(passToCheck: string) {
    return bcrypt.compareSync(passToCheck, this.password);
  }

  /** Returns a fresh JWT for the current user */
  get JWT() {
    return jwt.sign({ username: this.username } as JWTContent, Configuration.secretKey, { expiresIn: Configuration.server.jwtExpirationTime });
  }

  /** Decodes the given JWT to get relevant content from it */
  static decodeJWT(token: string) {
    return jwt.decode(token) as JWTContent;
  }

  /** Verifies the given JWT. Throws an error if it is not valid */
  static verifyJWT(jwtString?: string) {
    if (!jwtString) throw new Error("Invalid JWT");
    return jwt.verify(jwtString, Configuration.secretKey);
  }
}
