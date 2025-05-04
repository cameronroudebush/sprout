import { Base, DBBase } from "./base";

/** This class defines shared user information available to the clients */
export class User extends DBBase {
  firstName: string;
  lastName: string;
  /** The current username for this user */
  username: string;
  admin: boolean = false;

  get prettyName() {
    if (this.firstName == null && this.lastName == null) return this.username;
    return this.firstName + " " + this.lastName;
  }

  constructor(id: string, username: string, firstName: string, lastName: string, admin = false) {
    super(id);
    this.username = username;
    this.firstName = firstName;
    this.lastName = lastName;
    this.admin = admin;
  }
}

export class UserCreationResponse extends Base {
  username: string;

  /** If the creation was a success. If this is filled out, it was not successful and this will be the error. */
  success: string | undefined;

  constructor(username: string, success: string | undefined) {
    super();
    this.username = username;
    this.success = success;
  }
}

export class UserCreationRequest extends Base {
  username: string;
  password: string;

  constructor(username: string, password: string) {
    super();
    this.username = username;
    this.password = password;
  }
}

/** Required content to be sent when a user tries to login. Can use username/password or JWT */
export class UserLoginRequest extends Base {
  username: string;
  password: string;
  jwt?: string;

  constructor(username: string, password: string, jwt?: string) {
    super();
    this.username = username;
    this.password = password;
    this.jwt = jwt;
  }
}

/** Content that will be responded when the login request occurs */
export class UserLoginResponse extends Base {
  user: User;
  jwt: string;

  constructor(user: User, jwt: string) {
    super();
    this.user = user;
    this.jwt = jwt;
  }
}
