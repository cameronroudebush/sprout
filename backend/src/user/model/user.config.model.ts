import { EncryptionTransformer } from "@backend/core/decorator/encryption.decorator";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { ChartRange } from "@backend/user/model/chart.range.model";
import { User } from "@backend/user/model/user.model";
import { ApiHideProperty, ApiProperty } from "@nestjs/swagger";
import { Exclude } from "class-transformer";
import { IsBoolean, IsEnum, IsString } from "class-validator";
import { JoinColumn, OneToOne } from "typeorm";

/**
 * This class defines user configuration options per user
 */
@DatabaseDecorators.entity()
export class UserConfig extends DatabaseBase {
  /** If we should hide balances on the users display */
  @DatabaseDecorators.column({ nullable: false, default: false })
  @IsBoolean()
  privateMode: boolean;

  /** The net worth range to display by default */
  @DatabaseDecorators.column({ nullable: false, default: "oneDay", type: "varchar" })
  @ApiProperty({ enum: ChartRange, enumName: "ChartRangeEnum" })
  @IsEnum(ChartRange)
  netWorthRange: ChartRange;

  /** This property defines the SimpleFIN URL for obtaining data from the necessary endpoint. This will be encrypted in the database. */
  @DatabaseDecorators.column({ type: "varchar", nullable: true, transformer: new EncryptionTransformer() })
  @EncryptionTransformer.decorateAPIProperty()
  @IsString()
  simpleFinToken?: string;

  /** This property defines the Gemini API token for LLM use. */
  @DatabaseDecorators.column({ type: "varchar", nullable: true, transformer: new EncryptionTransformer() })
  @EncryptionTransformer.decorateAPIProperty()
  @IsString()
  geminiKey?: string;

  /** If we should require biometrics to view the app and if we should hide the app in the background */
  @DatabaseDecorators.column({ nullable: false, default: false })
  @IsBoolean()
  secureMode: boolean;

  @OneToOne(() => User, (user) => user.config, { onDelete: "CASCADE" })
  @JoinColumn({ name: "userId" })
  @ApiHideProperty()
  @Exclude()
  user!: User;

  constructor(privateMode: boolean, netWorthRange: UserConfig["netWorthRange"], secureMode: boolean) {
    super();
    this.privateMode = privateMode;
    this.netWorthRange = netWorthRange;
    this.secureMode = secureMode;
  }
}
