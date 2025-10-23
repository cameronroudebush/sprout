import { CreditAccountType, CryptoAccountType, DepositoryAccountType, InvestmentAccountType, LoanAccountType } from "@backend/account/model/account.type";
import { ApiProperty } from "@nestjs/swagger";
import { IsEnum, IsOptional, IsString } from "class-validator";

const AllAccountSubTypes: Record<string, string> = {
  ...Object.fromEntries(Object.entries(DepositoryAccountType).map(([key, value]) => [value, key])),
  ...Object.fromEntries(Object.entries(CreditAccountType).map(([key, value]) => [value, key])),
  ...Object.fromEntries(Object.entries(InvestmentAccountType).map(([key, value]) => [value, key])),
  ...Object.fromEntries(Object.entries(LoanAccountType).map(([key, value]) => [value, key])),
  ...Object.fromEntries(Object.entries(CryptoAccountType).map(([key, value]) => [value, key])),
};

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
