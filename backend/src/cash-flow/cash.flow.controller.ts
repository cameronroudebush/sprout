import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { AuthGuard } from "@backend/core/guard/auth.guard";
import { User } from "@backend/user/model/user.model";
import { Controller, Get, Query } from "@nestjs/common";
import { ApiOkResponse, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { CashFlowService } from "./cash.flow.service";
import { CashFlowSpending } from "./model/api/cash.flow.spending.dto";
import { CashFlowStats } from "./model/api/cash.flow.stats.dto";
import { SankeyData } from "./model/api/sankey.dto";

/** Dynamically attaches the expected query information for re-use in cash flow endpoints that allows us to better specify what cash flow data we want. */
function attachQuery() {
  return function <TFunction extends Function>(target: Object, propertyKey?: string | symbol, descriptor?: TypedPropertyDescriptor<TFunction>) {
    ApiQuery({ name: "year", required: true, type: Number, description: "The year we want the cash flow data for." })(target, propertyKey!, descriptor!);
    ApiQuery({
      name: "month",
      required: false,
      type: Number,
      description: "The month we want the cash flow data for. If not given, assumes we want the whole year.",
    })(target, propertyKey!, descriptor!);
    ApiQuery({
      name: "day",
      required: false,
      type: Number,
      description:
        "The day we want the cash flow data for. If not given, assumes to include the entire month. If the month is not included in your query, this is ignored.",
    })(target, propertyKey!, descriptor!);
    ApiQuery({ name: "accountId", required: false, type: String, description: "The ID of the account to retrieve transactions from." })(
      target,
      propertyKey!,
      descriptor!,
    );
  };
}

/** This controller contains information about cash flow with respect to categories for the authenticated user. */
@Controller("cash-flow")
@ApiTags("Cash Flow")
@AuthGuard.attach()
export class CashFlowController {
  constructor(private readonly cashFlowService: CashFlowService) {}

  @Get("sankey")
  @ApiOperation({
    summary: "Get sankey data by query.",
    description: "Retrieves a model that can be used to render a sankey diagram based on the current authenticated users cash flow.",
  })
  @ApiOkResponse({ description: "Sankey built successfully.", type: SankeyData })
  @attachQuery()
  async getSankey(
    @CurrentUser() user: User,
    @Query("year") year: number,
    @Query("month") month?: number,
    @Query("day") day?: number,
    @Query("accountId") accountId?: string,
  ) {
    return this.cashFlowService.buildSankey(user, year, month, day, accountId);
  }

  @Get("stats")
  @ApiOperation({
    summary: "Get cash flow stats data by query.",
    description: "Retrieves stats for the users cash flow in more basic terms. Tracking how much went out and how much came in.",
  })
  @ApiOkResponse({ description: "Cash flow calculated successfully.", type: CashFlowStats })
  @attachQuery()
  async getStats(
    @CurrentUser() user: User,
    @Query("year") year: number,
    @Query("month") month?: number,
    @Query("day") day?: number,
    @Query("accountId") accountId?: string,
  ) {
    const { totalIncome, totalExpense, transactionCount, largestExpense } = await this.cashFlowService.calculateFlows(user, year, month, day, accountId);
    return new CashFlowStats(totalExpense, totalIncome, transactionCount, largestExpense ?? undefined);
  }

  @Get("spending")
  @ApiOperation({
    summary: "Get cash flow spending stats per month.",
    description: "Returns monthly spending breakdown for the requested look-back period, isolating top N categories.",
  })
  @ApiOkResponse({ description: "Spending calculated successfully.", type: CashFlowSpending })
  async getSpending(
    @CurrentUser() user: User,
    @Query("months") monthsQuery?: number,
    @Query("categories") categoriesLimitQuery?: number,
  ): Promise<CashFlowSpending> {
    const months = monthsQuery || 6; // Default to 6 months
    const categoriesLimit = categoriesLimitQuery || 4; // Default to top 4
    return this.cashFlowService.calculateMonthlySpending(user, months, categoriesLimit);
  }
}
