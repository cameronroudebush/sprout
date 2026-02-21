import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { User } from "@backend/user/model/user.model";
import { ApiProperty } from "@nestjs/swagger";
import { Exclude } from "class-transformer";
import { ManyToOne } from "typeorm";

/** This model tracks background syncing progress. Tracks if we have ran into errors when a sync was ran. */
@DatabaseDecorators.entity()
export class Sync extends DatabaseBase {
  /** When this was started */
  @DatabaseDecorators.column({ nullable: false })
  declare time: Date;

  @DatabaseDecorators.column({ nullable: false })
  @ApiProperty({
    enum: ["in-progress", "complete", "failed"],
    description: "The status of the sync job",
  })
  declare status: "in-progress" | "complete" | "failed";

  @DatabaseDecorators.column({ nullable: true })
  declare failureReason?: string;

  /** This user properly allows us to track if this sync was for a specific user */
  @ManyToOne(() => User, { nullable: true, onDelete: "CASCADE", eager: false })
  @Exclude()
  declare user?: User;
}
