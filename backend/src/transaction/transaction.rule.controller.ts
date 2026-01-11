import { Category } from "@backend/category/model/category.model";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { AuthGuard } from "@backend/core/guard/auth.guard";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { TransactionRule } from "@backend/transaction/model/transaction.rule.model";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { User } from "@backend/user/model/user.model";
import {
  BadRequestException,
  Body,
  Controller,
  DefaultValuePipe,
  Delete,
  Get,
  NotFoundException,
  Param,
  ParseBoolPipe,
  Patch,
  Post,
  Query,
} from "@nestjs/common";
import { ApiBody, ApiCreatedResponse, ApiNotFoundResponse, ApiOkResponse, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";

/** This controller provides the endpoint for all Transaction rules content */
@Controller("transaction-rule")
@ApiTags("Transaction Rule")
@AuthGuard.attach()
export class TransactionRuleController {
  constructor(
    private readonly sseService: SSEService,
    private readonly transactionRuleService: TransactionRuleService,
  ) {}

  @Get()
  @ApiOperation({
    summary: "Get transaction rules.",
    description: "Retrieves all transaction rules for the authenticated user.",
  })
  @ApiOkResponse({ description: "Transaction rules found successfully.", type: [TransactionRule] })
  async get(@CurrentUser() user: User) {
    return await TransactionRule.find({ where: { user: { id: user.id } }, order: { order: "ASC" }, relations: ["category.parentCategory"] });
  }

  @Delete(":id")
  @ApiOperation({
    summary: "Delete transaction rule by ID.",
    description: "Deletes a transaction rule by the given ID then runs a transaction update to re-categorize transactions.",
  })
  @ApiOkResponse({ description: "Transaction rule deleted successfully." })
  @ApiNotFoundResponse({ description: "Transaction rule with the specified ID not found." })
  async delete(@Param("id") id: string, @CurrentUser() user: User) {
    // Grab it from the database to make sure it exists for this user
    const ruleInDb = await TransactionRule.findOne({ where: { id: id, user: { id: user.id } } });
    if (ruleInDb == null) throw new NotFoundException("Failed to locate matching rule in database.");

    await TransactionRule.deleteById(ruleInDb?.id);
    await this.transactionRuleService.applyRulesToTransactions(user);
    this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);
    return `Transaction rule with ID ${id} deleted successfully.`;
  }

  @Patch(":id")
  @ApiOperation({
    summary: "Edit transaction rule.",
    description: "Edits a transaction rule by the given ID.",
  })
  @ApiOkResponse({ description: "Transaction rule updated successfully.", type: TransactionRule })
  @ApiNotFoundResponse({ description: "Transaction rule with the specified ID not found, does not belong to the user, or doesn't have a matching category." })
  @ApiBody({ type: TransactionRule })
  async edit(@Param("id") id: string, @CurrentUser() user: User, @Body() rule: TransactionRule) {
    const matchingRule = await TransactionRule.findOne({ where: { id: id, user: { id: user.id } } });
    if (matchingRule == null) throw new NotFoundException("Failed to find matching rule to update.");
    const newRule = TransactionRule.fromPlain({ ...rule, id: matchingRule.id });
    newRule.user = user;
    // Validate category
    if (newRule.category != null) {
      const matchingCat = await Category.findOne({ where: { id: newRule.category?.id, user: { id: user.id } } });
      if (matchingCat == null) throw new NotFoundException("Failed to locate matching category for transactional rule.");
      else newRule.category = matchingCat;
    }
    // Validate type
    if (newRule.type !== "amount" && newRule.type !== "description") throw new BadRequestException("Given type is not valid.");
    newRule.value = newRule.value.trim();
    const updatedRule = await newRule.update();

    // Perform validation on editing the order. If the order has changed, we need to re-organize the other rules.
    if (newRule.order != null && newRule.order !== matchingRule.order) await this.transactionRuleService.reorderRules(user, matchingRule.id, newRule.order);

    // Run the match updates
    await this.transactionRuleService.applyRulesToTransactions(user);
    this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);

    return TransactionRule.findOne({ where: { id: updatedRule.id }, relations: ["category.parentCategory"] });
  }

  @Post()
  @ApiOperation({
    summary: "Creates a new transaction rule.",
    description: "Creates a new transaction rule based on the given content and runs a processor so we can organize our current transactions.",
  })
  @ApiCreatedResponse({ description: "Transaction rule added successfully.", type: TransactionRule })
  @ApiNotFoundResponse({ description: "Failed to locate a matching category for this transaction rule based on given content." })
  @ApiBody({ type: TransactionRule })
  async create(@Body() data: TransactionRule, @CurrentUser() user: User) {
    const rule = TransactionRule.fromPlain(data);
    rule.value = rule.value.trim();
    rule.user = user;

    if (rule.category) {
      const category = await Category.findOne({ where: { id: rule.category.id, user: { id: user.id } } });
      if (category == null) throw new NotFoundException("Failed to locate a matching category for this rule");
    }

    // Find the last order and add this to the end
    const lastRule = await TransactionRule.findOne({ where: { user: { id: user.id } }, order: { order: "DESC" } });
    if (lastRule != null) rule.order = lastRule.order + 1;
    else rule.order = 0;

    // Insert the rule
    await rule.insert();

    // Run the match updates
    await this.transactionRuleService.applyRulesToTransactions(user);
    this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);

    return rule;
  }

  @Post("apply")
  @ApiOperation({
    summary: "Re-apply all transaction rules",
    description:
      "Triggers a manual synchronization process that evaluates all transaction rules against the user's existing transactions and updates their categories or metadata accordingly. If matches could not be found, those transactions will not be updated.",
  })
  @ApiQuery({
    name: "force",
    type: Boolean,
    required: false,
    description: "If true, also overwrites manually edited transactions. By default this is disabled so a users category changes are preserved.",
  })
  @ApiQuery({
    name: "resetCategories",
    type: Boolean,
    required: false,
    description: "If true, resets categories to null for transactions that do not match any current rules.",
  })
  @ApiOkResponse({
    description: "Rules were successfully processed and applied to transactions.",
  })
  async applyRules(
    @CurrentUser() user: User,
    @Query("force", new DefaultValuePipe(false), ParseBoolPipe) force: boolean,
    @Query("resetCategories", new DefaultValuePipe(false), ParseBoolPipe) resetCategories: boolean,
  ): Promise<void> {
    await this.transactionRuleService.applyRulesToTransactions(user, undefined, undefined, force, resetCategories);
    // Inform of refresh required
    this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);
  }
}
