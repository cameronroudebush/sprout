import { IsISO8601, IsNumber, IsOptional, IsString } from "class-validator";

/** Represents a major market index that we can relate other stocks to for how today is performing */
export class MarketIndexDto {
  @IsString()
  symbol: string;

  @IsString()
  name: string;

  @IsNumber()
  price: number;

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
    this.name = quote.shortName || quote.longName || "Unknown";
    this.price = quote.regularMarketPrice ?? 0;
    this.currency = quote.currency || "USD";
    this.change = quote.regularMarketChange ?? 0;
    this.changePercent = quote.regularMarketChangePercent ?? 0;
    this.lastUpdated = quote.regularMarketTime ? new Date(quote.regularMarketTime * 1000).toISOString() : new Date().toISOString();
  }
}
