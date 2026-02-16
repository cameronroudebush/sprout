import { Base } from "@backend/core/model/base";
import { ApiProperty } from "@nestjs/swagger";
import { Type } from "class-transformer";
import { IsDate } from "class-validator";

/** A class that represents the date/value for a point in time for our total historical data. This data is used to display timelines of change. */
export class HistoricalDataPoint {
  @ApiProperty({ description: "The date of the record" })
  date: Date;

  @ApiProperty({ description: "The numerical value" })
  value: number;

  constructor(date: Date, value: number) {
    this.date = date;
    this.value = value;
  }
}

/** This class represents a point in time of an entity history. */
export class EntityHistoryDataPoint extends Base {
  percentChange?: number;
  valueChange: number;

  @ApiProperty({
    description: "When our data starts",
    example: "2025-07-21T17:32:28Z",
  })
  @Type(() => Date)
  @IsDate()
  start: Date;

  constructor(valueChange: number, percentChange: number, start: Date) {
    super();
    this.valueChange = valueChange;
    this.percentChange = percentChange;
    this.start = start;
  }
}

/** This class represents the value of an entity (account, stock, etc.) over time. */
export class EntityHistory extends Base {
  last1Day: EntityHistoryDataPoint;
  last7Days: EntityHistoryDataPoint;
  lastMonth: EntityHistoryDataPoint;
  lastThreeMonths: EntityHistoryDataPoint;
  lastSixMonths: EntityHistoryDataPoint;
  lastYear: EntityHistoryDataPoint;
  allTime: EntityHistoryDataPoint;

  /** Some entity history data may have a connected Id of what it relates to. This could be something like an account Id. */
  connectedId?: string;

  constructor(
    last1Day: EntityHistoryDataPoint,
    last7Days: EntityHistoryDataPoint,
    lastMonth: EntityHistoryDataPoint,
    lastThreeMonths: EntityHistoryDataPoint,
    lastSixMonths: EntityHistoryDataPoint,
    lastYear: EntityHistoryDataPoint,
    allTime: EntityHistoryDataPoint,
  ) {
    super();
    this.last1Day = last1Day;
    this.last7Days = last7Days;
    this.lastMonth = lastMonth;
    this.lastThreeMonths = lastThreeMonths;
    this.lastSixMonths = lastSixMonths;
    this.lastYear = lastYear;
    this.allTime = allTime;
  }

  /** Returns a zeroed entity history */
  static get plain() {
    const zeroPoint = new EntityHistoryDataPoint(0, 0, new Date());
    return new EntityHistory(zeroPoint, zeroPoint, zeroPoint, zeroPoint, zeroPoint, zeroPoint, zeroPoint);
  }
}
