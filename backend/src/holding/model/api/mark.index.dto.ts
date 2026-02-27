import { IsEnum, IsISO8601, IsNumber, IsOptional, IsString } from "class-validator";

export enum MarketState {
  REGULAR = "REGULAR",
  CLOSED = "CLOSED",
  PRE = "PRE",
  POST = "POST",
  PREPRE = "PREPRE", // Occurs very early morning
  POSTPOST = "POSTPOST", // Occurs late evening
}

export class MarketIndexDto {
  @IsString()
  symbol: string;

  @IsString()
  name: string;

  @IsNumber()
  price: number;

  @IsNumber()
  @IsOptional()
  previousClose?: number;

  @IsNumber()
  @IsOptional()
  dayLow?: number;

  @IsNumber()
  @IsOptional()
  dayHigh?: number;

  @IsEnum(MarketState)
  @IsOptional()
  marketState?: MarketState;

  @IsString()
  @IsOptional()
  currency?: string;

  @IsNumber()
  change: number;

  @IsNumber()
  changePercent: number;

  @IsISO8601()
  lastUpdated: string;

  constructor(quote: any) {
    this.symbol = quote.symbol;
    this.name = quote.shortName || quote.longName || quote.symbol;
    this.price = quote.regularMarketPrice ?? 0;
    this.previousClose = quote.regularMarketPreviousClose;
    this.dayLow = quote.regularMarketDayLow;
    this.dayHigh = quote.regularMarketDayHigh;
    this.marketState = quote.marketState as MarketState;
    this.currency = quote.currency || "USD";
    this.change = quote.regularMarketChange ?? 0;
    this.changePercent = quote.regularMarketChangePercent ?? 0;
    this.lastUpdated = quote.regularMarketTime ? new Date(quote.regularMarketTime).toISOString() : new Date().toISOString();
  }
}
