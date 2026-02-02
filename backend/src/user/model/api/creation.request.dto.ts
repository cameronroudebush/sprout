import { Configuration } from "@backend/config/core";
import { Base } from "@backend/core/model/base";
import { IsNotEmpty, IsString, ValidateIf } from "class-validator";

/**
 * Required content to be sent when a user tries to get created for local strategy. Not required
 * for OIDC user creation as info is pulled from the tokens
 */
export class UserCreationRequest extends Base {
  @ValidateIf(() => Configuration.server.auth.type !== "oidc")
  @IsNotEmpty({ message: "Username is required when not using OIDC" })
  @IsString()
  username: string;

  @ValidateIf(() => Configuration.server.auth.type !== "oidc")
  @IsNotEmpty({ message: "Password is required when not using OIDC" })
  @IsString()
  password: string;

  constructor(username: string, password: string) {
    super();
    this.username = username;
    this.password = password;
  }
}
