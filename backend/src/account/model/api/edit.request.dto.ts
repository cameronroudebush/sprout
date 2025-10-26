import { AccountSubType } from "@backend/account/model/account.sub.type";
import { ApiProperty } from "@nestjs/swagger";
import { IsEnum, IsOptional, IsString } from "class-validator";

const AllAccountSubTypes = Object.values(AccountSubType);

/** The minified model of what can be edited in an account */
export class AccountEditRequest {
  @IsString()
  @IsOptional()
  name?: string;

  @ApiProperty({
    description: "The specific subtype of the account",
    enum: AllAccountSubTypes,
    example: "checking",
  })
  @IsEnum(AllAccountSubTypes, {
    message: `subType must be one of the following values: ${Object.values(AllAccountSubTypes).join(", ")}`,
  })
  @IsString()
  @IsOptional()
  subType?: string;
}
