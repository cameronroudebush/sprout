import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { BudgetHistoryResponseDto } from "@backend/budget/model/api/budget.history.dto";
import { BudgetOverviewResponseDto } from "@backend/budget/model/api/budget.overview.dto";
import { CreateBudgetDto } from "@backend/budget/model/api/create.budget.dto";
import { UpdateBudgetDto } from "@backend/budget/model/api/update.budget.dto";
import { Budget } from "@backend/budget/model/budget.model";
import { EnabledGuard } from "@backend/config/guard/enabled.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { User } from "@backend/user/model/user.model";
import { Body, Controller, Delete, Get, Param, ParseIntPipe, Patch, Post, Query } from "@nestjs/common";
import { ApiBody, ApiOkResponse, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { BudgetService } from "./budget.service";

@Controller("budget")
@ApiTags("Budget")
@AuthGuard.attach()
export class BudgetController {
  constructor(private readonly budgetService: BudgetService) {}

  @Get()
  @ApiOperation({
    summary: "Get all user budgets.",
    description: "Retrieves all configured budget targets for the current user.",
  })
  @ApiOkResponse({ description: "Budgets retrieved successfully.", type: [Budget] })
  async getAllBudgets(@CurrentUser() user: User) {
    return await this.budgetService.getAllBudgets(user);
  }

  @Post()
  @ApiOperation({
    summary: "Create a new category budget.",
    description: "Creates a new monthly budget target for a category.",
  })
  @ApiOkResponse({ description: "Budget created successfully.", type: Budget })
  @ApiBody({ type: CreateBudgetDto })
  @EnabledGuard.attachDemoMode()
  async createBudget(@CurrentUser() user: User, @Body() dto: CreateBudgetDto) {
    return await this.budgetService.createBudget(user, dto);
  }

  @Patch(":id")
  @ApiOperation({
    summary: "Update a budget target.",
    description: "Updates an existing budget target's monthly amount.",
  })
  @ApiOkResponse({ description: "Budget updated successfully.", type: Budget })
  @ApiBody({ type: UpdateBudgetDto })
  @EnabledGuard.attachDemoMode()
  async updateBudget(@CurrentUser() user: User, @Param("id") budgetId: string, @Body() dto: UpdateBudgetDto) {
    return await this.budgetService.updateBudget(user, budgetId, dto);
  }

  @Delete(":id")
  @ApiOperation({
    summary: "Delete a budget target.",
    description: "Deletes an existing category budget target.",
  })
  @ApiOkResponse({ description: "Budget deleted successfully." })
  @EnabledGuard.attachDemoMode()
  async deleteBudget(@CurrentUser() user: User, @Param("id") budgetId: string) {
    await this.budgetService.deleteBudget(user, budgetId);
    return { success: true };
  }

  @Get("overview")
  @ApiOperation({
    summary: "Get budget overview.",
    description: "Retrieves budget targets vs actual spending breakdown for a given month and year.",
  })
  @ApiQuery({ name: "year", required: false, type: Number })
  @ApiQuery({ name: "month", required: false, type: Number })
  @ApiOkResponse({ description: "Budget overview generated successfully.", type: BudgetOverviewResponseDto })
  async getBudgetOverview(
    @CurrentUser() user: User,
    @Query("year", new ParseIntPipe({ optional: true })) year?: number,
    @Query("month", new ParseIntPipe({ optional: true })) month?: number,
  ) {
    return await this.budgetService.getBudgetOverview(user, year, month);
  }

  @Get("history")
  @ApiOperation({
    summary: "Get historical budget performance.",
    description: "Retrieves historical monthly performance looking backwards in time.",
  })
  @ApiQuery({ name: "months", required: false, type: Number, description: "Number of months to look back (default 6)." })
  @ApiQuery({ name: "categoryId", required: false, type: String, description: "Filter history to a specific category." })
  @ApiOkResponse({ description: "Budget history generated successfully.", type: BudgetHistoryResponseDto })
  async getBudgetHistory(
    @CurrentUser() user: User,
    @Query("months", new ParseIntPipe({ optional: true })) months = 6,
    @Query("categoryId") categoryId?: string,
  ) {
    return await this.budgetService.getBudgetHistory(user, months, categoryId);
  }
}
