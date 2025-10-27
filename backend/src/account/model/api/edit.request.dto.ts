import { AccountSubType } from "@backend/account/model/account.sub.type";
import { ApiProperty } from "@nestjs/swagger";
import { IsOptional, IsString } from "class-validator";

/** The minified model of what can be edited in an account */
export class AccountEditRequest {
  @IsString()
  @IsOptional()
  name?: string;

  @IsString()
  @IsOptional()
  @ApiProperty({ enum: AccountSubType, enumName: "AccountSubTypeEnum", required: false })
  subType?: AccountSubType;
}
