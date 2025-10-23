import { Controller, Get } from "@nestjs/common";
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiParam, ApiTags } from "@nestjs/swagger";
import { AccountService } from "./account.service";

/**
 * This controller provides the endpoint for all Account related content
 */
@Controller("account")
@ApiBearerAuth()
@ApiTags("Account")
export class AccountController {
  constructor(private readonly accountService: AccountService) {}

  @Get()
  @ApiOperation({ summary: "Get a simple hello message" })
  @ApiOkResponse({ description: "Returns a simple hello message." })
  getHello(): string {
    return this.accountService.getHello();
  }

  @Get(":id")
  @ApiOperation({ summary: "Get an account by ID" })
  @ApiParam({
    name: "id",
    description: "The ID of the account to retrieve",
    type: String,
  })
  @ApiOkResponse({ description: "Returns the account with the specified ID." })
  getAccountById(id: string): string {
    // In a real application, you would fetch the account from a database
    // using the accountService. For this example, we'll just return a string.
    return `Account with ID: ${id}`;
  }
}
