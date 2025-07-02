import { Base } from "@backend/model/base";
import { User } from "@backend/model/user";

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
