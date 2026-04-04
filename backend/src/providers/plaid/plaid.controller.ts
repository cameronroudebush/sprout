import { Account } from "@backend/account/model/account.model";
import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { PlaidLinkDTO } from "@backend/providers/plaid/model/api/link.dto";
import { PlaidLinkTokenDTO } from "@backend/providers/plaid/model/api/link.token.dto";
import { PlaidProviderService } from "@backend/providers/plaid/plaid.provider.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { Body, Controller, InternalServerErrorException, Logger, Post, Query } from "@nestjs/common";
import { ApiBody, ApiCreatedResponse, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";

/** This controller provides endpoints for plaid specific functionality */
@Controller("provider/plaid")
@ApiTags("Provider")
@AuthGuard.attach()
export class PlaidProviderController {
  private readonly logger = new Logger("provider:controller:plaid");
  constructor(
    private readonly sseService: SSEService,
    private readonly plaidProviderService: PlaidProviderService,
  ) {}

  @Post("create-link-token")
  @ApiOperation({ summary: "Create a Plaid link token" })
  @ApiCreatedResponse({ description: "Link created successfully.", type: PlaidLinkTokenDTO })
  @ApiQuery({ name: "institutionId", required: false, type: String })
  async createLinkToken(@CurrentUser() user: User, @Query("institutionId") institutionId?: string) {
    try {
      return await this.plaidProviderService.generateLinkToken(user, institutionId);
    } catch (error) {
      this.logger.error(error);
      throw new InternalServerErrorException("Failed to generate Plaid link token.");
    }
  }

  /**
   * This is called after the user successfully logs into their bank via Plaid.
   * It exchanges the public token for an access token and creates the accounts.
   */
  @Post("exchange-token")
  @ApiOperation({
    summary: "Exchange Public Token",
    description: "Finalizes the link by exchanging the public token and saving accounts to the DB.",
  })
  @ApiCreatedResponse({ description: "Accounts linked successfully.", type: [Account] })
  @ApiBody({ type: PlaidLinkDTO })
  async exchangeAndLink(@CurrentUser() user: User, @Body() dto: PlaidLinkDTO) {
    try {
      const accounts = await this.plaidProviderService.exchangeAndCreateAccounts(user, dto);
      // Force an update
      this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);
      return accounts;
    } catch (error) {
      this.logger.error(`Failed to link Plaid accounts for user ${user.id}:`, error);
      throw new InternalServerErrorException("An error occurred while linking your accounts.");
    }
  }
}
