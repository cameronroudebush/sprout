import { ApiProperty } from "@nestjs/swagger";
import { IsEmail, IsOptional } from "class-validator";

/** DTO that contains anything a user may want to update */
export class UpdateUserDto {
  @ApiProperty({ example: "new-email@example.com", description: "The new email for the user." })
  @IsEmail()
  @IsOptional()
  email?: string;
}
