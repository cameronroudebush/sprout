import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsNumber, IsString, Min } from "class-validator";

export class CreateBudgetDto {
  @ApiProperty({ description: "The ID of the category for this budget." })
  @IsString()
  @IsNotEmpty()
  categoryId!: string;

  @ApiProperty({ description: "The target monthly budget amount.", example: 500.0 })
  @IsNumber()
  @Min(0)
  amount!: number;
}
