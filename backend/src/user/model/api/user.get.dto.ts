import { User } from "@backend/user/model/user.model";
import { ApiProperty } from "@nestjs/swagger";

/** A DTO specifying what information is returned about a user */
export class UserGetDTO {
  @ApiProperty()
  username: string;

  constructor(username: string) {
    this.username = username;
  }

  /** Creates this information from the given user */
  static fromUser(user: User) {
    return new UserGetDTO(user.username);
  }
}
