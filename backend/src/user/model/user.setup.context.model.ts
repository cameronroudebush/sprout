import { Base } from "@backend/core/model/base";

/**
 * Class representing a temporary "Ghost" user that hasn't actually been created yet.
 */
export class UserSetupContext extends Base {
  id: string;
  username: string;
  firstName?: string;
  lastName?: string;
  admin: boolean;

  constructor(id: string, username: string, firstName?: string, lastName?: string, admin: boolean = false) {
    super();
    this.id = id;
    this.username = username;
    this.firstName = firstName;
    this.lastName = lastName;
    this.admin = admin;
  }
}
