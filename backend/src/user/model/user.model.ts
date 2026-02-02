import { Category } from "@backend/category/model/category.model";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { UserCreationResponse } from "@backend/user/model/api/creation.response.dto";
import { UserConfig } from "@backend/user/model/user.config.model";
import { BadRequestException } from "@nestjs/common";
import { ApiHideProperty } from "@nestjs/swagger";
import bcrypt from "bcrypt";
import { Exclude } from "class-transformer";
import { JoinColumn, OneToOne } from "typeorm";

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

  /** Hashed password to verify for login. **You should never set this directly**. This value can be null for non local auth strategies.*/
  @DatabaseDecorators.column({ nullable: true })
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

  /** Checks the database to see if the username is in use and throws an error if so. */
  static async checkIfUsernameIsInUser(username: string) {
    if (!username.trim()) throw new BadRequestException("No username given");
    if ((await User.find({ where: { username } })).length > 0) throw new Error("Username is in use");
  }

  /** Validates the given plain-text password passes password requirements. Throws an error if it doesn't. */
  static async validatePassword(_password: string) {
    if (_password.length < 8) throw new Error("Password must be at least 8 characters long.");
    if (!/[A-Z]/.test(_password)) throw new Error("Password must contain at least one uppercase letter.");
    return;
  }

  /**
   * Creates a user with the given content and returns it. Could throw errors depending upon issues.
   * If a password is not given, you will not be able to login with standard username/password login.
   */
  static async createUser(u: Partial<User> & { username: string; admin: boolean }) {
    await User.checkIfUsernameIsInUser(u.username);
    let user = User.fromPlain(u);
    if (u.password) {
      await User.validatePassword(u.password);
      const hashedPassword = User.hashPassword(u.password);
      user.password = hashedPassword;
    }
    user.config = await UserConfig.fromPlain({ user: user }).insert();
    user = await user.insert();
    await Category.insertMany(Category.getDefaultCategoriesForUser(user));
    return UserCreationResponse.fromPlain({ username: user.username });
  }
}
