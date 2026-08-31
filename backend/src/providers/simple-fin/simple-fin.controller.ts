import { Account } from "@backend/account/model/account.model";
import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { Configuration } from "@backend/config/core";
import { EnabledGuard } from "@backend/config/guard/enabled.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { SimpleFINProviderService } from "@backend/providers/simple-fin/simple-fin.provider.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { User } from "@backend/user/model/user.model";
import { Body, Controller, Get, Post } from "@nestjs/common";
import { ApiBody, ApiCreatedResponse, ApiNotFoundResponse, ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";

@Controller("provider/simple-fin")
@ApiTags("Provider")
@AuthGuard.attach()
@EnabledGuard.attach(Configuration.providers.simpleFIN.enabled)
export class SimpleFinProviderController {
  constructor(
    private readonly simpleFinProviderService: SimpleFINProviderService,
    private readonly sseService: SSEService,
    private readonly transactionRuleService: TransactionRuleService,
  ) {}

  @Get()
  @ApiOperation({
    summary: "Get accounts from the simple-fin provider that are not yet synced.",
    description: "Retrieves accounts that the user has not yet linked.",
  })
  @ApiOkResponse({ description: "Provider accounts found successfully.", type: [Account] })
  @ApiNotFoundResponse({ description: "Provider with the specified name not found." })
  async getAccounts(@CurrentUser() user: User) {
    // Moved the logic into the service so we don't accidentally insert accounts during a preview
    return await this.simpleFinProviderService.getUnlinkedAccounts(user);
  }

  @Post("link")
  @ApiOperation({
    summary: "Link the new given accounts from simple-fin.",
    description: "Given some accounts, links the new accounts to the current user.",
  })
  @ApiCreatedResponse({ description: "Provider accounts linked successfully.", type: [Account] })
  @ApiBody({ type: [Account] })
  @EnabledGuard.attachDemoMode()
  async linkAccounts(@Body() accountsToLink: Account[], @CurrentUser() user: User): Promise<Account[]> {
    const accountIds = accountsToLink.map((a) => a.id);

    // Delegate to the ProviderBase template! This handles Institutions, Account History, Holdings, and Transactions automatically.
    const syncResults = await this.simpleFinProviderService.exchangeAndCreateAccounts(user, accountIds);

    const addedAccounts: Account[] = [];

    // Apply any manual UI overrides (like SubType) chosen by the user on the frontend
    for (const result of syncResults) {
      const frontendOverride = accountsToLink.find((a) => a.id === result.account.id);
      if (frontendOverride && frontendOverride.subType != null) {
        result.account.subType = frontendOverride.subType;
        Account.validateSubType(result.account.subType);
        await result.account.update();
      }
      addedAccounts.push(result.account);
    }

    // Run transaction rules on the newly pulled transactions
    await this.transactionRuleService.applyRulesToTransactions(user, undefined, true);
    this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);

    return addedAccounts;
  }
}
