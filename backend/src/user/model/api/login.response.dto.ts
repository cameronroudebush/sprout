import { Base } from "@backend/core/model/base";
import { User } from "@backend/user/model/user.model";

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
