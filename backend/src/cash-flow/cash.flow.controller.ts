import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { DailySpendingCalendarResponseDTO } from "@backend/cash-flow/model/api/daily.spending.dto";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { User } from "@backend/user/model/user.model";
import { Controller, Get, ParseIntPipe, Query } from "@nestjs/common";
import { ApiOkResponse, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { format } from "date-fns";
import { CashFlowService } from "./cash.flow.service";
import { CashFlowComparisonDTO } from "./model/api/cash.flow.comparison.dto";
import { CashFlowSpending } from "./model/api/cash.flow.spending.dto";
import { CashFlowStats } from "./model/api/cash.flow.stats.dto";
import { CashFlowTrendStats } from "./model/api/cash.flow.trend.dto";
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

  @Get("trend")
  @ApiOperation({
    summary: "Get cash flow trend by month.",
    description: "Returns monthly trend breakdown for the requested look-back period.",
  })
  @ApiOkResponse({ type: CashFlowTrendStats, isArray: true })
  async getTrend(@CurrentUser() user: User, @Query("months") monthsQuery?: number) {
    const monthsToTrace = monthsQuery || 6; // Default to 6 months
    const trendStats: CashFlowTrendStats[] = [];
    const currentDate = new Date();
    for (let i = 0; i < monthsToTrace; i++) {
      const targetDate = new Date(currentDate.getFullYear(), currentDate.getMonth() - i, 1);
      const year = targetDate.getFullYear();
      const month = targetDate.getMonth() + 1;
      const label = format(targetDate, "MMM ''yy");
      const { totalIncome, totalExpense } = await this.cashFlowService.calculateFlows(user, year, month);
      const topValue = totalIncome;
      const bottomValue = Math.abs(totalExpense);
      const trendValue = topValue - bottomValue;
      trendStats.push(new CashFlowTrendStats(label, topValue, bottomValue, trendValue));
    }
    return trendStats.reverse();
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

  @Get("comparison-timeline")
  @ApiOperation({ summary: "Get spending progression over time for comparison." })
  @ApiOkResponse({ type: CashFlowComparisonDTO })
  @ApiQuery({ name: "targetMonth", required: false, type: Number })
  async getComparisonTimeline(@CurrentUser() user: User, @Query("targetYear", ParseIntPipe) targetYear: number, @Query("targetMonth") targetMonth?: string) {
    const now = new Date();
    const parsedMonth = targetMonth ? parseInt(targetMonth, 10) : undefined;
    const isMonthlyMode = parsedMonth !== undefined;

    // Current scope handles either this month (e.g., now.getMonth() + 1) or this complete year (undefined)
    const [current, target] = await Promise.all([
      this.cashFlowService.getSpendingTimeline(user, now.getFullYear(), isMonthlyMode ? now.getMonth() + 1 : undefined),
      this.cashFlowService.getSpendingTimeline(user, targetYear, parsedMonth),
    ]);

    // Determine label layout text formats responsively
    const currentLabel = isMonthlyMode ? format(now, "MMM yyyy") : format(now, "yyyy");
    const targetLabel = isMonthlyMode ? format(new Date(targetYear, parsedMonth - 1), "MMM yyyy") : format(new Date(targetYear, 0), "yyyy");

    return new CashFlowComparisonDTO(current, target, currentLabel, targetLabel);
  }

  @Get("daily-calendar-spending")
  @ApiOperation({
    summary: "Get discrete daily spending totals for a target month canvas calendar widget view.",
  })
  @ApiOkResponse({
    description: "Map of days to spending amounts returned successfully.",
    type: DailySpendingCalendarResponseDTO,
  })
  @ApiQuery({ name: "year", required: true, type: Number })
  @ApiQuery({ name: "month", required: true, type: Number })
  async getDailyCalendarSpending(@CurrentUser() user: User, @Query("year", ParseIntPipe) year: number, @Query("month", ParseIntPipe) month: number) {
    return await this.cashFlowService.getDailySpendingMap(user, year, month);
  }
}
