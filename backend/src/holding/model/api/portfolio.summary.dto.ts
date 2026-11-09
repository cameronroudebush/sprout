import { ApiProperty } from "@nestjs/swagger";

export class PortfolioSummaryDto {
  @ApiProperty({ description: "Total current market value of the user's portfolio in their configured currency.", example: 125000.5 })
  totalValue!: number;

  @ApiProperty({ description: "Estimated value change for holdings with prices available during the current market session.", example: 1250.5 })
  dayChange!: number;

  @ApiProperty({ description: "Estimated weighted percentage change for holdings with prices available during the current market session.", example: 1.01 })
  dayChangePercent!: number;

  @ApiProperty({ description: "Whether any holdings are excluded from current-session performance because their prices have not updated yet.", example: true })
  hasUnpricedHoldings!: boolean;

  @ApiProperty({ description: "Symbols of mutual funds whose NAVs have not updated since the latest market close.", type: [String], example: ["VFIAX"] })
  pendingNavSymbols!: string[];

  constructor(partial: Partial<PortfolioSummaryDto>) {
    Object.assign(this, partial);
  }
}
