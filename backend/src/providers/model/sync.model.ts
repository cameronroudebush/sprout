import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { ProviderType } from "@backend/providers/base/provider.type";
import { SyncTriggerType } from "@backend/providers/model/sync.type";
import { User } from "@backend/user/model/user.model";
import { ApiHideProperty, ApiProperty } from "@nestjs/swagger";
import { Exclude } from "class-transformer";
import { IsEnum } from "class-validator";
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

  @DatabaseDecorators.column({ nullable: false })
  provider!: ProviderType;

  /** This user properly allows us to track if this sync was for a specific user */
  @ManyToOne(() => User, { nullable: true, onDelete: "CASCADE", eager: false })
  @ApiHideProperty()
  @Exclude({ toPlainOnly: true })
  declare user?: User;

  /**
   * Identifies what initiated this sync run.
   * Used by post-sync processing to differentiate scheduled notification batches
   * from silent webhooks or user-initiated refreshes.
   */
  @DatabaseDecorators.column({ type: "varchar", default: SyncTriggerType.SCHEDULED })
  @ApiHideProperty()
  @IsEnum(SyncTriggerType)
  triggerType: SyncTriggerType = SyncTriggerType.SCHEDULED;

  /**
   * Indicates whether the `PostSyncProcessingJob` queue worker has finished
   * handling this sync record (triggering SSE updates, AI overviews, and push notifications). Only handled with certain {@link SyncTriggerType} types.
   */
  @DatabaseDecorators.column({ default: false })
  @ApiHideProperty()
  processed: boolean = false;
}
