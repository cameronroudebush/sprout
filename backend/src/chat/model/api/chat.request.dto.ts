import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString } from "class-validator";

/** A model to allow the apps to utilize the AI endpoints and provides you the ability to decide what to ask the LLM. */
export class ChatRequestDTO {
  @ApiProperty({ example: "How much did I spend on groceries in the last 30 days?", description: "The message to send to the AI" })
  @IsString()
  @IsNotEmpty()
  message: string;

  constructor(message: string) {
    this.message = message;
  }
}
