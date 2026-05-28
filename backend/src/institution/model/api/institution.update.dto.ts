import { InstitutionIconType } from "@backend/institution/model/institution.icon.type";
import { ApiProperty } from "@nestjs/swagger";
import { IsEnum, IsNotEmpty } from "class-validator";

/** DTO that specifies what we can update for an institution */
export class UpdateInstitutionRequest {
  @ApiProperty({
    enum: InstitutionIconType,
    enumName: "InstitutionIconType",
    description: "The preferred logo variant style for this institution.",
    example: InstitutionIconType.SYMBOL,
  })
  @IsEnum(InstitutionIconType, {
    message: 'iconType must be either "icon" or "symbol"',
  })
  @IsNotEmpty()
  iconType!: InstitutionIconType;
}
