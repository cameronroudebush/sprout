import { Account } from "@backend/account/model/account.model";
import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { Configuration } from "@backend/config/core";
import { EnabledGuard } from "@backend/config/guard/enabled.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { ProviderType } from "@backend/providers/base/provider.type";
import { CoinbaseProviderService } from "@backend/providers/coinbase/coinbase.provider.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { User } from "@backend/user/model/user.model";
import { BadRequestException, Controller, InternalServerErrorException, Post } from "@nestjs/common";
import { ApiCreatedResponse, ApiOperation, ApiTags } from "@nestjs/swagger";

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

  @Post("link")
  @ApiOperation({
    summary: "Link Coinbase account.",
    description: "Fetches active balances from Coinbase API credentials and links the unified Coinbase Wallet.",
  })
  @ApiCreatedResponse({ description: "Provider account linked successfully.", type: Account })
  @EnabledGuard.attachDemoMode()
  async linkAccount(@CurrentUser() user: User): Promise<Account> {
    const existingAccounts = await Account.find({
      where: { user: { id: user.id }, provider: ProviderType.coinbase },
    });
    if (existingAccounts.length > 0) throw new BadRequestException("Coinbase account is already linked.");
    const syncResults = await this.coinbaseProviderService.exchangeAndCreateAccounts(user, undefined);
    const linkedAccount = syncResults[0]?.account;
    if (!linkedAccount) throw new InternalServerErrorException("Failed to link Coinbase account.");
    await this.transactionRuleService.applyRulesToTransactions(user, undefined, true);
    this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);
    return linkedAccount;
  }
}
