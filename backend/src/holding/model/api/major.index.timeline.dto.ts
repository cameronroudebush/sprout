import { ApiProperty } from "@nestjs/swagger";

export class MajorIndexTimelinePoint {
  @ApiProperty({ type: Date, example: "2026-05-29T13:30:00.000Z" })
  date!: Date;

  @ApiProperty({ type: Number, description: "The raw closing nominal price.", example: 7580.06 })
  value!: number;

  @ApiProperty({ type: Number, description: "The percentage change relative to day one of the lookback window.", example: 0.81 })
  changePercent!: number;

  constructor(partial: Partial<MajorIndexTimelineDto>) {
    Object.assign(this, partial);
  }
}

export class MajorIndexTimelineDto {
  @ApiProperty({
    description: "The official Yahoo Finance ticker index symbol code.",
    example: "^GSPC",
    type: String,
  })
  symbol!: string;

  @ApiProperty({
    description: "The readable corporate clean name matching the index symbol.",
    example: "S&P 500",
    type: String,
  })
  name!: string;

  @ApiProperty({
    description: "The hexadecimal color token string representing this brand asset.",
    example: "#2196F3",
    type: String,
  })
  color!: string;

  @ApiProperty({
    description: "The historical performance point ledger tracking both raw price and performance percentages.",
    type: [MajorIndexTimelinePoint],
  })
  timeline!: MajorIndexTimelinePoint[];

  constructor(partial: Partial<MajorIndexTimelineDto>) {
    Object.assign(this, partial);
  }
}
