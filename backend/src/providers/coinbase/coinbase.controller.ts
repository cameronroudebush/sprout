import { Account } from "@backend/account/model/account.model";
import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { Configuration } from "@backend/config/core";
import { EnabledGuard } from "@backend/config/guard/enabled.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { CoinbaseProviderService } from "@backend/providers/coinbase/coinbase.provider.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { User } from "@backend/user/model/user.model";
import { Body, Controller, Get, Post } from "@nestjs/common";
import { ApiBody, ApiCreatedResponse, ApiNotFoundResponse, ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";

@Controller("provider/coinbase")
@ApiTags("Provider")
@AuthGuard.attach()
@EnabledGuard.attach(Configuration.providers.coinbase.enabled)
export class CoinbaseProviderController {
  constructor(
    private readonly coinbaseProviderService: CoinbaseProviderService,
    private readonly sseService: SSEService,
    private readonly transactionRuleService: TransactionRuleService,
  ) {}

  @Get()
  @ApiOperation({
    summary: "Get accounts from the coinbase provider that are not yet synced.",
    description: "Retrieves accounts that the user has not yet linked.",
  })
  @ApiOkResponse({ description: "Provider accounts found successfully.", type: [Account] })
  @ApiNotFoundResponse({ description: "Provider with the specified name not found." })
  async getAccounts(@CurrentUser() user: User) {
    const accounts = await this.coinbaseProviderService.getUnlinkedAccounts(user);
    accounts.map((x) => (x.id = x.providerAccountId));
    return accounts;
  }

  @Post("link")
  @ApiOperation({
    summary: "Link the new given accounts from coinbase.",
    description: "Given some accounts, links the new accounts to the current user.",
  })
  @ApiCreatedResponse({ description: "Provider accounts linked successfully.", type: [Account] })
  @ApiBody({ type: [Account] })
  @EnabledGuard.attachDemoMode()
  async linkAccounts(@Body() accountsToLink: Account[], @CurrentUser() user: User): Promise<Account[]> {
    const accountIds = accountsToLink.map((a) => a.id);

    const syncResults = await this.coinbaseProviderService.exchangeAndCreateAccounts(user, accountIds);

    const addedAccounts: Account[] = [];

    for (const result of syncResults) {
      const frontendOverride = accountsToLink.find((a) => a.id === result.account.id);
      if (frontendOverride && frontendOverride.subType != null) {
        result.account.subType = frontendOverride.subType;
        Account.validateSubType(result.account.subType);
        await result.account.update();
      }
      addedAccounts.push(result.account);
    }

    await this.transactionRuleService.applyRulesToTransactions(user, undefined, true);
    this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);

    return addedAccounts;
  }
}
