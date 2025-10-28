import { Configuration } from "@backend/config/core";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { UserConfig } from "@backend/user/model/user.config.model";
import { ApiHideProperty } from "@nestjs/swagger";
import bcrypt from "bcrypt";
import { Exclude } from "class-transformer";
import jwt from "jsonwebtoken";
import { JoinColumn, OneToOne } from "typeorm";

/** JWT object content that will be included */
type JWTContent = { username: string };

@DatabaseDecorators.entity()
export class User extends DatabaseBase {
  @DatabaseDecorators.column({ nullable: true })
  firstName?: string;

  @DatabaseDecorators.column({ nullable: true })
  lastName?: string;

  @DatabaseDecorators.column()
  username: string;

  @DatabaseDecorators.column({ default: false })
  admin: boolean;

  /** Hashed password in the database to compare against */
  @DatabaseDecorators.column()
  @Exclude()
  @ApiHideProperty()
  password!: string;

  @OneToOne(() => UserConfig, { eager: true, onDelete: "CASCADE" })
  @JoinColumn()
  config: UserConfig;

  get prettyName() {
    if (this.firstName == null && this.lastName == null) return this.username;
    return this.firstName + " " + this.lastName;
  }

  constructor(username: string, firstName: string, lastName: string, admin = false, config: UserConfig) {
    super();
    this.username = username;
    this.firstName = firstName;
    this.lastName = lastName;
    this.admin = admin;
    this.config = config;
  }

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
    return jwt.sign({ username: this.username } as JWTContent, Configuration.secretKey, { expiresIn: Configuration.server.jwtExpirationTime as any });
  }

  /** Decodes the given JWT to get relevant content from it */
  static decodeJWT(token: string) {
    return jwt.decode(token) as JWTContent;
  }

  /** Verifies the given JWT. Throws an error if it is not valid */
  static verifyJWT(jwtString?: string) {
    if (!jwtString) throw new Error("Invalid JWT");
    return jwt.verify(jwtString, Configuration.secretKey) as JWTContent;
  }

  /** Checks the database to see if the username is in use and throws an error if so. */
  static async checkIfUsernameIsInUser(username: string) {
    if ((await User.find({ where: { username } })).length > 0) throw new Error("Username is in use,");
  }

  /** Validates the given plain-text password passes password requirements. Throws an error if it doesn't. */
  static async validatePassword(_password: string) {
    if (_password.length < 8) throw new Error("Password must be at least 8 characters long.");
    if (!/[A-Z]/.test(_password)) throw new Error("Password must contain at least one uppercase letter.");
    return;
  }

  /** Creates a user with the given content and returns it. Could throw errors depending upon issues. */
  static async createUser(username: string, password: string, admin = false) {
    await User.checkIfUsernameIsInUser(username);
    await User.validatePassword(password);
    const hashedPassword = User.hashPassword(password);
    const user = User.fromPlain({ username, admin });
    user.password = hashedPassword;
    user.config = await UserConfig.fromPlain({ user: user }).insert();
    return await user.insert();
  }
}
