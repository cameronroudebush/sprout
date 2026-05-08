import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString } from "class-validator";

/** This DTO represents a request to merge an account */
export class AccountMergeDTO {
  @ApiProperty({
    description: "The ID of the source account to merge and delete.",
  })
  @IsString()
  @IsNotEmpty()
  sourceId: string;

  constructor(sourceId: string) {
    this.sourceId = sourceId;
  }
}
