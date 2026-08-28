import { ProviderType } from "@backend/providers/base/provider.type";
import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsArray, IsBoolean, IsEnum, IsOptional } from "class-validator";

/** DTO that specifies configuration options for manual syncs */
export class ManualSyncDto {
  @ApiPropertyOptional({
    description: "Force trigger sync even if another sync is currently in progress.",
    default: false,
    example: false,
  })
  @IsOptional()
  @IsBoolean()
  force?: boolean = false;

  @ApiPropertyOptional({
    description: "Specific provider types to sync. Omit or leave empty to sync all connected providers.",
    enum: ProviderType,
    enumName: "ProviderTypeEnum",
    isArray: true,
    nullable: true,
  })
  @IsOptional()
  @IsArray()
  @IsEnum(ProviderType, { each: true })
  providers?: ProviderType[];
}
