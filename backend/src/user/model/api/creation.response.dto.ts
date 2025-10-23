import { Base } from "@backend/core/model/base";

/** Content that will be responded when a user creation request occurs */
export class UserCreationResponse extends Base {
  username: string;

  constructor(username: string) {
    super();
    this.username = username;
  }
}
