import { ApiProperty } from "@nestjs/swagger";
import { IsNumber, Min } from "class-validator";

export class UpdateBudgetDto {
  @ApiProperty({ description: "The updated target monthly budget amount.", example: 600.0 })
  @IsNumber()
  @Min(0)
  amount!: number;
}
