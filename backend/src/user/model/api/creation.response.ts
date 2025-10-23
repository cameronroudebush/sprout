import { Base } from "@backend/core/model/base";

/** Content that will be responded when a user creation request occurs */
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
