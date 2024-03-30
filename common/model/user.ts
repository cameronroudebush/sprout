import { Base } from "./base";

/** This class defines shared user information available to the clients */
export class User extends Base {
  /** The current username for this user */
  username: string;

  constructor(username: string) {
    super();
    this.username = username;
  }
}

/** Required content to be sent when a user tries to login */
export class UserLoginRequest extends Base {
  username: string;
  password: string;

  constructor(username: string, password: string) {
    super();
    this.username = username;
    this.password = password;
  }
}

/** Content that will be responded when the login request occurs */
export class UserLoginResponse extends Base {
  username: string;
  jwt: string;

  constructor(username: string, jwt: string) {
    super();
    this.username = username;
    this.jwt = jwt;
  }
}
