import { ApiProperty } from "@nestjs/swagger";
import { IsEnum, IsNotEmpty, IsString } from "class-validator";

/** How much data to include within the requests */
export enum ChatTimeframe {
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

  constructor(message: string) {
    this.message = message;
  }
}
