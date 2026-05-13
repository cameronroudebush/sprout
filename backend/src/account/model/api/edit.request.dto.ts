import { AccountSubType } from "@backend/account/model/account.sub.type";
import { AccountType } from "@backend/account/model/account.type";
import { ApiProperty } from "@nestjs/swagger";
import { IsEnum, IsNumber, IsOptional, IsString } from "class-validator";

/** The minified model of what can be edited in an account */
export class AccountEditRequest {
  @IsString()
  @IsOptional()
  name?: string;

  @IsString()
  @IsOptional()
  @ApiProperty({ enum: AccountSubType, enumName: "AccountSubTypeEnum", required: false })
  @IsEnum(AccountSubType)
  subType?: AccountSubType;

  @IsString()
  @IsOptional()
  @ApiProperty({ enum: AccountType, enumName: "AccountTypeEnum", required: false })
  @IsEnum(AccountType)
  type?: AccountType;

  @IsNumber()
  @IsOptional()
  interestRate?: number;
}
