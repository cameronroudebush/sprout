import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { Holding } from "@backend/holding/model/holding.model";
import { Institution } from "@backend/institution/model/institution.model";
import { SimpleFINProviderService } from "@backend/providers/simple-fin/simple-fin.provider.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { User } from "@backend/user/model/user.model";
import { Body, Controller, Get, Post } from "@nestjs/common";
import { ApiBody, ApiCreatedResponse, ApiNotFoundResponse, ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";
import { randomUUID } from "crypto";

/** This controller provides endpoints for simple-fin specific provider content */
@Controller("provider/simple-fin")
@ApiTags("Provider")
@AuthGuard.attach()
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
    const existingAccounts = await Account.find({ where: { user: { id: user.id } } });
    const providerAccounts = await Promise.all(
      (await this.simpleFinProviderService.get(user, true)).map(async (x) => {
        const account = x.account;
        const matchingInstitution = await Institution.findOne({ where: { user: { id: user.id }, name: account.institution.name } });
        if (matchingInstitution == null) {
          // New institution
          account.institution.id = randomUUID();
        } else account.institution = matchingInstitution;
        return x.account;
      }),
    );
    return providerAccounts.filter((providerAccount) => !existingAccounts.some((existingAccount) => existingAccount.id === providerAccount.id));
  }

  @Post("link")
  @ApiOperation({
    summary: "Link the new given accounts from simple-fin.",
    description: "Given some accounts, links the new accounts to the current user.",
  })
  @ApiCreatedResponse({ description: "Provider accounts linked successfully.", type: [Account] })
  @ApiBody({ type: [Account] })
  async linkAccounts(@Body() accountsToLink: [Account], @CurrentUser() user: User) {
    const providerAccounts = await this.simpleFinProviderService.get(user, true);
    // Add these new accounts to the database
    const addedAccounts: Account[] = [];
    for (const account of accountsToLink) {
      const matchingAccount = providerAccounts.find((z) => z.account.name === account.name);
      if (matchingAccount) {
        matchingAccount.account.user = user;
        // Try to find a matching institution first if it exists
        const matchingInstitution = await Institution.findOne({ where: { user: { id: user.id }, name: matchingAccount.account.institution.name } });
        if (matchingInstitution) matchingAccount.account.institution = matchingInstitution;
        else matchingAccount.account.institution.user = user; // Enforce user for our institution to not allow overwrites
        matchingAccount.account.subType = account.subType;
        if (account.subType != null) Account.validateSubType(account.subType);
        const newAccount = await matchingAccount.account.insert(false);
        // Insert one day old history
        AccountHistory.insertForNewAccount(newAccount);
        // Insert matching transactions
        matchingAccount.transactions.map((x) => (x.account = matchingAccount.account));
        await Transaction.insertMany(matchingAccount.transactions);
        // Run transaction rules
        await this.transactionRuleService.applyRulesToTransactions(user, undefined, true);
        // Insert holdings
        matchingAccount.holdings.map((x) => (x.account = matchingAccount.account));
        await Holding.insertMany(matchingAccount.holdings);
        addedAccounts.push(matchingAccount.account);
      }
    }
    this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);
    return addedAccounts;
  }
}
