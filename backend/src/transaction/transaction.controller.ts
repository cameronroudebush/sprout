import { Controller, Get } from "@nestjs/common";
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";
import { TransactionService } from "./transaction.service";

/**
 * This controller provides the endpoint for all Transaction related content
 */
@Controller("transaction")
@ApiBearerAuth()
@ApiTags("Transaction")
export class TransactionController {
  constructor(private readonly transactionService: TransactionService) {}

  @Get()
  @ApiOperation({ summary: "Get a simple hello message" })
  @ApiOkResponse({ description: "Returns a simple hello message." })
  getHello(): string {
    return this.transactionService.getHello();
  }
}
