import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsBoolean, IsEnum, IsNotEmpty, IsOptional, IsString } from "class-validator";

/** How much data to include within the requests */
export enum ChatTimeframe {
  /** Actually passes two days because one day may exclude included data depending on time of day */
  oneDay = "oneDay",
  threeMonths = "threeMonths",
  sixMonths = "sixMonths",
  oneYear = "oneYear",
}

/** A model to allow the apps to utilize the AI endpoints and provides you the ability to decide what to ask the LLM. */
export class ChatRequestDTO {
  @ApiProperty({ example: "How much did I spend on groceries in the last 30 days?", description: "The message to send to the AI" })
  @IsString()
  @IsNotEmpty()
  message: string;

  @ApiProperty({
    description: "The historical timeframe to include in context.",
    enum: ChatTimeframe,
    default: ChatTimeframe.threeMonths,
    required: true,
  })
  @IsEnum(ChatTimeframe)
  timeframe!: ChatTimeframe;

  @ApiPropertyOptional({
    description: "Whether the LLM is allowed to generate chart JSON blocks.",
    default: true,
  })
  @IsOptional()
  @IsBoolean()
  allowCharts?: boolean;

  constructor(message: string) {
    this.message = message;
  }
}
