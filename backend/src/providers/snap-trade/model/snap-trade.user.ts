import { EncryptionTransformer } from "@backend/core/decorator/encryption.decorator";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { User } from "@backend/user/model/user.model";
import { ApiHideProperty } from "@nestjs/swagger";
import { Exclude } from "class-transformer";
import { IsString } from "class-validator";
import { JoinColumn, OneToOne } from "typeorm";

/** Database model tracking SnapTrade authorization credentials. */
@DatabaseDecorators.entity()
export class SnapTradeUser extends DatabaseBase {
  /** The user this snap trade info belongs to */
  @OneToOne(() => User, { eager: true, onDelete: "CASCADE" })
  @JoinColumn()
  @ApiHideProperty()
  @Exclude()
  user: User;

  /** The secret key used to authenticate requests for this user's data. Encrypted in the database. */
  @DatabaseDecorators.column({ type: "varchar", nullable: true, transformer: new EncryptionTransformer() })
  @EncryptionTransformer.decorateAPIProperty()
  @IsString()
  userSecret: string;

  constructor(user: User, userSecret: string) {
    super();
    this.user = user;
    this.userSecret = userSecret;
  }
}
