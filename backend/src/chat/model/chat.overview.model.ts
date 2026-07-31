import { ChatOverviewType } from "@backend/chat/model/chat.overview.type";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { User } from "@backend/user/model/user.model";
import { ApiHideProperty, ApiProperty } from "@nestjs/swagger";
import { Exclude } from "class-transformer";
import { IsEnum } from "class-validator";
import { JoinColumn, ManyToOne } from "typeorm";

/** This class provides a way of tracking chat overviews based on the requested content tye. */
@DatabaseDecorators.entity()
@DatabaseDecorators.compositeUnique<ChatOverview>("user", "type")
export class ChatOverview extends DatabaseBase {
  @ManyToOne(() => User, { onDelete: "CASCADE" })
  @JoinColumn()
  @ApiHideProperty()
  @Exclude()
  user: User;

  @DatabaseDecorators.column({ nullable: false })
  time: Date;

  @DatabaseDecorators.column({ nullable: false })
  text: string;

  @DatabaseDecorators.column({ nullable: false, type: "varchar" })
  @IsEnum(ChatOverviewType)
  @ApiProperty({ enum: ChatOverviewType, enumName: "ChatOverviewTypeEnum", required: true })
  type: ChatOverviewType;

  constructor(user: User, text: string, type: ChatOverviewType, time = new Date()) {
    super();
    this.user = user;
    this.time = time;
    this.text = text;
    this.type = type;
  }
}
