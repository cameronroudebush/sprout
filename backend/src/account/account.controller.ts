import { Account } from "@backend/account/model/account.model";
import { AccountEditRequest } from "@backend/account/model/api/edit.request.dto";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { AuthGuard } from "@backend/core/guard/auth.guard";
import { Holding } from "@backend/holding/model/holding.model";
import { Institution } from "@backend/institution/model/institution.model";
import { JobsService } from "@backend/jobs/jobs.service";
import { Sync } from "@backend/jobs/model/sync.model";
import { ProviderService } from "@backend/providers/provider.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { User } from "@backend/user/model/user.model";
import { Body, Controller, Delete, Get, InternalServerErrorException, NotFoundException, Param, Patch, Post, Put, Query } from "@nestjs/common";
import { ApiBody, ApiCreatedResponse, ApiNotFoundResponse, ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";
import { startOfDay } from "date-fns";
import { MoreThanOrEqual } from "typeorm";
import { SSEService } from "../sse/sse.service";

/**
 * This controller provides the endpoint for all Account related content
 */
@Controller("account")
@ApiTags("Account")
@AuthGuard.attach()
export class AccountController {
  constructor(
    private readonly sseService: SSEService,
    private readonly providerService: ProviderService,
    private readonly transactionRuleService: TransactionRuleService,
    private readonly jobService: JobsService,
  ) {}

  @Get(":id")
  @ApiOperation({
    summary: "Get account by ID.",
    description: "Retrieves an account by the given ID.",
  })
  @ApiOkResponse({ description: "Account found successfully.", type: Account })
  @ApiNotFoundResponse({ description: "Account with the specified ID not found." })
  async getById(@Param("id") id: string, @CurrentUser() user: User) {
    const acc = await Account.findOne({ where: { id: id, user: { id: user.id } } });
    if (acc == null) throw new NotFoundException();
    else return acc;
  }

  @Delete(":id")
  @ApiOperation({
    summary: "Delete account by ID.",
    description: "Deletes an account by the given ID.",
  })
  @ApiOkResponse({ description: "Account deleted successfully." })
  @ApiNotFoundResponse({ description: "Account with the specified ID not found." })
  async delete(@Param("id") id: string, @CurrentUser() user: User) {
    const matchingAccountForUser = await Account.findOne({ where: { id: id, user: { id: user.id } } });
    if (matchingAccountForUser == null) throw new NotFoundException(`Account with ID ${id} not found or does not belong to the user.`);
    const deleteResult = await Account.deleteById(id);
    if (deleteResult.affected === 0) throw new InternalServerErrorException(`No results when deleting account with ${id}`);
    this.sseService.sendToUser(user, SSEEventType.SYNC);
    return `Account with ID ${id} deleted successfully.`;
  }

  @Patch(":id")
  @ApiOperation({
    summary: "Edit account.",
    description: "Edits an account by the given ID.",
  })
  @ApiOkResponse({ description: "Account updated successfully.", type: Account })
  @ApiNotFoundResponse({ description: "Account with the specified ID not found or does not belong to the user." })
  @ApiBody({ type: AccountEditRequest })
  async edit(@Param("id") id: string, @CurrentUser() user: User, @Body() updatedAccount: AccountEditRequest) {
    const matchingAccount = await Account.findOne({ where: { id: id, user: { id: user.id } } });
    if (matchingAccount == null) throw new NotFoundException(`Account with ID ${id} not found or does not belong to the user.`);

    // Update only the allowed fields
    matchingAccount.name = updatedAccount.name ?? matchingAccount.name;
    matchingAccount.subType = updatedAccount.subType ?? (matchingAccount.subType as any);
    // Perform the update, return the result.
    const result = await matchingAccount.update();
    this.sseService.sendToUser(user, SSEEventType.SYNC);
    return result;
  }

  @Get()
  @ApiOperation({
    summary: "Get accounts.",
    description: "Retrieves all accounts for the authenticated user.",
  })
  @ApiOkResponse({ description: "Accounts found successfully.", type: [Account] })
  async getAccounts(@CurrentUser() user: User) {
    return await Account.find({ where: { user: { id: user.id } } });
  }

  @Get("provider/:name")
  @ApiOperation({
    summary: "Get accounts from a provider that are not yet synced.",
    description: "Retrieves accounts from a specified provider that the user has not yet linked.",
  })
  @ApiOkResponse({ description: "Provider accounts found successfully.", type: [Account] })
  @ApiNotFoundResponse({ description: "Provider with the specified name not found." })
  async getProviderAccounts(@Param("name") name: string, @CurrentUser() user: User) {
    const matchingProvider = this.providerService.getAll().find((x) => x.config.name === name);
    if (matchingProvider == null) throw new NotFoundException(`Failed to locate matching provider for ${name}`);
    const existingAccounts = await Account.find({ where: { user: user } });
    const providerAccounts = (await matchingProvider.get(user, true)).map((x) => x.account);
    return providerAccounts.filter((providerAccount) => !existingAccounts.some((existingAccount) => existingAccount.id === providerAccount.id));
  }

  @Post("provider/:name/link")
  @ApiOperation({
    summary: "Link the new given accounts from a provider.",
    description: "Given some accounts and the provider info, links new accounts to the current user.",
  })
  @ApiCreatedResponse({ description: "Provider accounts linked successfully.", type: [Account] })
  @ApiBody({ type: [Account] })
  async linkProviderAccounts(@Param("name") name: string, @Body() accountsToLink: [Account], @CurrentUser() user: User) {
    const providerMatch = this.providerService.getAll().find((x) => x.config.name === name);
    if (providerMatch == null) throw new Error("Failed to locate matching provider");
    // We need to grab all the provider accounts again because we want to make sure we have correct data
    const providerAccounts = await providerMatch.get(user, true);
    // Add these new accounts to the database
    const addedAccounts: Account[] = [];
    for (const account of accountsToLink) {
      const matchingAccount = providerAccounts.find((z) => z.account.name === account.name);
      if (matchingAccount) {
        matchingAccount.account.user = user;
        // Try to find a matching institution first if it exists
        const matchingInstitution = await Institution.findOne({ where: { id: matchingAccount.account.institution.id } });
        if (matchingInstitution) matchingAccount.account.institution = matchingInstitution;
        matchingAccount.account.subType = account.subType;
        if (account.subType != null) Account.validateSubType(account.subType);
        await matchingAccount.account.insert(false);
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
    this.sseService.sendToUser(user, SSEEventType.SYNC);
    this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);
    return addedAccounts;
  }

  @Put("sync")
  @ApiOperation({
    summary: "Run a manual sync.",
    description: "Runs a manual sync to update all provider accounts.",
  })
  @ApiOkResponse({ description: "Manual sync completed successfully." })
  @AuthGuard.attach()
  async manualSync(@CurrentUser() user: User, @Query("force") force: boolean = false) {
    const runningSync = await Sync.findOne({
      where: {
        status: "in-progress",
        time: MoreThanOrEqual(startOfDay(new Date())),
      },
    });

    if (runningSync && !force) {
      throw new InternalServerErrorException("A sync is already in progress. Please wait for it to complete.");
    }

    const sync = await this.jobService.providerSyncJob.updateNow(user);
    // Inform of the completed sync
    this.sseService.sendToUser(user, SSEEventType.SYNC, sync);
  }
}
