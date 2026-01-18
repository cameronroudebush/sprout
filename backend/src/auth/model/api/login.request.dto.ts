import { Base } from "@backend/core/model/base";
import { IsNotEmpty, IsString } from "class-validator";

/** Required content to be sent when a user tries to login. Can use username/password. */
export class UsernamePasswordLoginRequest extends Base {
  @IsString()
  @IsNotEmpty()
  username: string;

  @IsString()
  @IsNotEmpty()
  password: string;

  constructor(username: string, password: string) {
    super();
    this.username = username;
    this.password = password;
  }
}

/** Required content to be sent when a user tries to login with JWT.*/
export class JWTLoginRequest extends Base {
  @IsString()
  @IsNotEmpty()
  jwt: string;

  constructor(jwt: string) {
    super();
    this.jwt = jwt;
  }
}
