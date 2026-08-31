import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountMergeDTO } from "@backend/account/model/api/account.merge.dto";
import { AccountEditRequest } from "@backend/account/model/api/edit.request.dto";
import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { EnabledGuard } from "@backend/config/guard/enabled.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { DatabaseService } from "@backend/database/database.service";
import { Holding } from "@backend/holding/model/holding.model";
import { Institution } from "@backend/institution/model/institution.model";
import { ProviderBase } from "@backend/providers/base/core";
import { PROVIDER_LIST_TOKEN } from "@backend/providers/model/constants";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionRule } from "@backend/transaction/model/transaction.rule.model";
import { User } from "@backend/user/model/user.model";
import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Inject,
  InternalServerErrorException,
  Logger,
  NotFoundException,
  Param,
  Patch,
  Post,
} from "@nestjs/common";
import { ApiBody, ApiNotFoundResponse, ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";

/**
 * This controller provides the endpoint for all Account related content
 */
@Controller("account")
@ApiTags("Account")
@AuthGuard.attach()
export class AccountController {
  private readonly logger = new Logger("controller:account");

  constructor(
    private readonly sseService: SSEService,
    private readonly databaseService: DatabaseService,
    @Inject(PROVIDER_LIST_TOKEN) private readonly providers: ProviderBase[],
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
  @EnabledGuard.attachDemoMode()
  async delete(@Param("id") id: string, @CurrentUser() user: User) {
    const matchingAccountForUser = await Account.findOne({
      where: { id: id, user: { id: user.id } },
      relations: { institution: true },
    });
    if (matchingAccountForUser == null) throw new NotFoundException(`Account with ID ${id} not found or does not belong to the user.`);
    const deleteResult = await Account.deleteById(id);
    if (deleteResult.affected === 0) throw new InternalServerErrorException(`No results when deleting account with ${id}`);
    // Attempt to clean up the institution if this was the last account using it
    await this.handleInstitutionCleanup(user, matchingAccountForUser.institution, matchingAccountForUser.provider);
    this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);
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
  @EnabledGuard.attachDemoMode()
  async edit(@Param("id") id: string, @CurrentUser() user: User, @Body() updatedAccount: AccountEditRequest) {
    const matchingAccount = await Account.findOne({ where: { id: id, user: { id: user.id } } });
    if (matchingAccount == null) throw new NotFoundException(`Account with ID ${id} not found or does not belong to the user.`);
    if (updatedAccount.name != null && updatedAccount.name.length < 5) throw new BadRequestException("Account names must be at least 5 characters.");

    // Update only the allowed fields
    matchingAccount.name = updatedAccount.name?.trim() ?? matchingAccount.name;
    matchingAccount.type = updatedAccount.type ?? matchingAccount.type;
    matchingAccount.subType = updatedAccount.subType ?? matchingAccount.subType;
    matchingAccount.interestRate = updatedAccount.interestRate ?? matchingAccount.interestRate;
    // Perform the update, return the result.
    const result = await matchingAccount.update();
    this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);
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

  @Post(":id/merge")
  @ApiOperation({
    summary: "Merge two accounts.",
    description:
      "Merges a source account into the target account by Id, updating all related historical data and deleting the source. Intended purely to migrate from one account as your base to another, in the event the provider changes the structure. You should consider the Target Id (in the query) will be the remaining account. The source account will be provided by the body.",
  })
  @ApiOkResponse({ description: "Accounts merged successfully.", type: Account })
  @ApiNotFoundResponse({ description: "One or both accounts not found or do not belong to the user." })
  @ApiBody({ type: AccountMergeDTO })
  @EnabledGuard.attachDemoMode()
  async mergeAccounts(@Param("id") targetId: string, @Body() request: AccountMergeDTO, @CurrentUser() user: User) {
    const { sourceId } = request;
    if (targetId === sourceId) throw new BadRequestException("Cannot merge an account into itself.");

    // Fetch both accounts ensuring they belong to the current user
    const targetAccount = await Account.findOne({ where: { id: targetId, user: { id: user.id } }, relations: { institution: true } });
    const sourceAccount = await Account.findOne({ where: { id: sourceId, user: { id: user.id } }, relations: { institution: true } });

    if (!targetAccount || !sourceAccount) throw new NotFoundException("One or both accounts were not found or do not belong to you.");
    if (targetAccount.type !== sourceAccount.type) throw new BadRequestException("Only accounts of the same type can be merged.");

    // Place the complex update into a transaction in case we fail
    const finalTargetAccount = await this.databaseService.source.transaction(async (manager) => {
      if (targetAccount.subType == null && sourceAccount.subType != null) {
        targetAccount.subType = sourceAccount.subType;
        await manager.save(targetAccount);
      }
      // Migrate transactions
      await manager.createQueryBuilder().update(Transaction).set({ accountId: targetId }).where("accountId = :sourceId", { sourceId }).execute();
      // Migrate transaction rules
      await manager.createQueryBuilder().update(TransactionRule).set({ accountId: targetId }).where("accountId = :sourceId", { sourceId }).execute();
      // Migrate Holdings
      await manager.createQueryBuilder().update(Holding).set({ accountId: targetId }).where("accountId = :sourceId", { sourceId }).execute();
      // Migrate Account History
      await manager.createQueryBuilder().update(AccountHistory).set({ account: targetAccount }).where("accountId = :sourceId", { sourceId }).execute();
      // Set yesterdays history equal to the source account, no matter what.
      AccountHistory.insertForNewAccount(targetAccount, true);
      // Delete Source Account
      await manager.remove(sourceAccount);

      return targetAccount;
    });

    // Check if the source account's institution is now empty for cleanup
    await this.handleInstitutionCleanup(user, sourceAccount.institution, sourceAccount.provider);

    // Notify Client
    this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);
    return finalTargetAccount;
  }

  /**
   * Checks if an institution has any remaining accounts attached to it.
   * If it is completely empty, it triggers external provider teardown
   * and deletes the Sprout Institution entity.
   */
  private async handleInstitutionCleanup(user: User, institution?: Institution, provider?: string) {
    if (!institution) return;
    // Count how many accounts are still tied to this specific institution
    const remainingAccounts = await Account.count({
      where: { institution: { id: institution.id } },
    });
    // If accounts remain, we silently exit and keep the institution alive
    if (remainingAccounts > 0) {
      this.logger.debug(`Institution ${institution.name} still has ${remainingAccounts} active account(s). Bypassing cleanup.`);
      return;
    }
    this.logger.log(`Institution ${institution.name} has 0 remaining accounts. Initiating full cleanup.`);
    // Handle unlinks
    for (const p of this.providers)
      if (provider === p.config.dbType) {
        await p.unlinkInstitution(user, institution.id);
        this.logger.log(`Cleaned up from ${p.config.name} successfully`);
      }
    // Remove from DB to cleanup
    await Institution.delete({ id: institution.id });
  }
}
