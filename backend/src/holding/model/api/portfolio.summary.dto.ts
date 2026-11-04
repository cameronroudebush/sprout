import { ApiProperty } from "@nestjs/swagger";

export class PortfolioSummaryDto {
  @ApiProperty({ description: "Total current market value of the user's portfolio in their configured currency.", example: 125000.5 })
  totalValue!: number;

  @ApiProperty({ description: "Estimated portfolio value change since the previous market close.", example: 1250.5 })
  dayChange!: number;

  @ApiProperty({ description: "Estimated portfolio percentage change since the previous market close.", example: 1.01 })
  dayChangePercent!: number;

  constructor(partial: Partial<PortfolioSummaryDto>) {
    Object.assign(this, partial);
  }
}
