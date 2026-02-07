import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { User } from "@backend/user/model/user.model";
import { ApiHideProperty } from "@nestjs/swagger";
import { Exclude } from "class-transformer";
import { ManyToOne } from "typeorm";

@DatabaseDecorators.entity()
export class Institution extends DatabaseBase {
  /** The URL for where this institution is */
  @DatabaseDecorators.column({ nullable: false })
  url: string;
  @DatabaseDecorators.column({ nullable: false })
  name: string;
  /** If this institution has connection errors and needs fixed */
  @DatabaseDecorators.column({ nullable: false })
  hasError: boolean;
  /** The user this institution record is scoped to */
  @ManyToOne(() => User, (u) => u.id, { nullable: false, onDelete: "CASCADE" })
  @ApiHideProperty()
  @Exclude()
  user: User;

  constructor(url: string, name: string, hasError: boolean, user: User) {
    super();
    this.url = url;
    this.name = name;
    this.hasError = hasError;
    this.user = user;
  }
}
