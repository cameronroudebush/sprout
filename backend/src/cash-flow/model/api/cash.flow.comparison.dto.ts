import { HistoricalDataPoint } from "@backend/net-worth/model/api/entity.history.dto";
import { ApiProperty } from "@nestjs/swagger";

export class CashFlowComparisonDTO {
  @ApiProperty({
    description: "Daily cumulative spending for the current month",
    type: [HistoricalDataPoint],
  })
  currentMonthData: HistoricalDataPoint[];

  @ApiProperty({
    description: "Daily cumulative spending for the target comparison month",
    type: [HistoricalDataPoint],
  })
  targetMonthData: HistoricalDataPoint[];

  @ApiProperty({ description: "Label for the current month (e.g., 'May 2026')" })
  currentMonthLabel: string;

  @ApiProperty({ description: "Label for the target comparison month (e.g., 'Apr 2026')" })
  targetMonthLabel: string;

  constructor(currentMonthData: HistoricalDataPoint[], targetMonthData: HistoricalDataPoint[], currentMonthLabel: string, targetMonthLabel: string) {
    this.currentMonthData = currentMonthData;
    this.targetMonthData = targetMonthData;
    this.currentMonthLabel = currentMonthLabel;
    this.targetMonthLabel = targetMonthLabel;
  }
}
