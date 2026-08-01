import { HistoricalDataPoint } from "@backend/net-worth/model/api/entity.history.dto";
import { ApiProperty } from "@nestjs/swagger";

export class LoanAmortizationSeries {
  @ApiProperty({ description: "The ID of the loan account." })
  accountId: string;

  @ApiProperty({ description: "The name of the loan account." })
  accountName: string;

  @ApiProperty({ description: "The projected months until the loan is fully paid off." })
  monthsToPayOff: number;

  @ApiProperty({ description: "The estimated monthly payment based on the transactions." })
  monthlyPayment: number;

  @ApiProperty({ description: "Color to display with this line series" })
  color: string;

  @ApiProperty({ type: [HistoricalDataPoint], description: "The monthly balance projection data points." })
  dataPoints: HistoricalDataPoint[];

  constructor(accountId: string, accountName: string, monthsToPayOff: number, monthlyPayment: number, color: string, dataPoints: HistoricalDataPoint[]) {
    this.accountId = accountId;
    this.accountName = accountName;
    this.monthsToPayOff = monthsToPayOff;
    this.dataPoints = dataPoints;
    this.monthlyPayment = monthlyPayment;
    this.color = color;
  }
}
