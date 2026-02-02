import { Configuration } from "@backend/config/core";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";

@Injectable()
export class UserService {
  /** Returns if users are allowed to be created because either it's first time setup or OIDC mode and new users are allowed. */
  async allowUserCreation() {
    if (Configuration.server.auth.type === "oidc") return Configuration.server.auth.oidc.allowNewUsers;
    else return (await User.count()) === 0;
  }
}
