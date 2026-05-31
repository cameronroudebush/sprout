import { EncryptionTransformer } from "@backend/core/decorator/encryption.decorator";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { Institution } from "@backend/institution/model/institution.model";
import { ApiHideProperty, ApiProperty } from "@nestjs/swagger";
import { Exclude } from "class-transformer";
import { IsOptional, IsString } from "class-validator";
import { JoinColumn, OneToOne } from "typeorm";

/** Database model that allows us to track additional plaid metadata about an institution and connection info for that institution. */
@DatabaseDecorators.entity()
export class PlaidInstitutionAsset extends DatabaseBase {
  @OneToOne(() => Institution, { onDelete: "CASCADE" })
  @JoinColumn({ name: "institutionId" })
  @ApiHideProperty()
  @Exclude()
  institution: Institution;

  /** The key to the users data. Encrypted in the database. */
  @DatabaseDecorators.column({ type: "varchar", nullable: true, transformer: new EncryptionTransformer() })
  @EncryptionTransformer.decorateAPIProperty()
  @IsString()
  accessToken: string;

  @DatabaseDecorators.column({ nullable: false })
  itemId: string;

  @DatabaseDecorators.column({ type: "varchar", nullable: true })
  @ApiProperty({ description: "Pagination cursor for Plaid sync" })
  @IsString()
  @IsOptional()
  syncCursor?: string;

  constructor(institution: Institution, accessToken: string, itemId: string) {
    super();
    this.institution = institution;
    this.accessToken = accessToken;
    this.itemId = itemId;
  }
}
