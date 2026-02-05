import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { User } from "@backend/user/model/user.model";
import { ApiHideProperty, ApiProperty } from "@nestjs/swagger";
import { Exclude } from "class-transformer";
import { IsString } from "class-validator";
import { ManyToOne } from "typeorm";

/** This class provides history to LLM chats. We only keep a certain amount per user. */
@DatabaseDecorators.entity()
export class ChatHistory extends DatabaseBase {
  static readonly DEFAULT_MODEL_TEXT = "Request failed. Try again later.";

  /** The user this chat belongs to */
  @ManyToOne(() => User, (u) => u.id)
  @ApiHideProperty()
  @Exclude()
  user: User;

  /** The time the chat occurred on */
  @DatabaseDecorators.column({ nullable: false })
  time: Date;

  /** The text of the chat */
  @DatabaseDecorators.column({ nullable: false })
  text: string;

  /** If the model is still thinking of a response for this one*/
  @DatabaseDecorators.column({ nullable: false, default: false })
  isThinking: boolean;

  /** Who said this message */
  @DatabaseDecorators.numericColumn({ nullable: false, type: "varchar" })
  @ApiProperty({
    enum: ["user", "model"],
    description: "Who said the message, either the LLM (AI) or the user.",
  })
  @IsString()
  role: "user" | "model";

  constructor(user: User, text: string, role: ChatHistory["role"], time = new Date(), isThinking = false) {
    super();
    this.user = user;
    this.time = time;
    this.text = text;
    this.role = role;
    this.isThinking = isThinking;
  }
}
