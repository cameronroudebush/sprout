import { Account } from "@backend/account/model/account.model";
import { AccountType } from "@backend/account/model/account.type";
import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { HoldingService } from "@backend/holding/holding.service";
import { MarketIndexDto } from "@backend/holding/model/api/mark.index.dto";
import { Holding } from "@backend/holding/model/holding.model";
import { NetWorthService } from "@backend/net-worth/net-worth.service";
import { User } from "@backend/user/model/user.model";
import { BadRequestException, Controller, Get, NotFoundException, Param, Query } from "@nestjs/common";
import { ApiOkResponse, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { EntityHistory, HistoricalDataPoint } from "../net-worth/model/api/entity.history.dto";

/** This controller contains information about {@link Holding} models which is stock information. */
@Controller("holding")
@ApiTags("Holding")
@AuthGuard.attach()
export class HoldingController {
  constructor(
    private readonly holdingService: HoldingService,
    private readonly netWorthService: NetWorthService,
  ) {}

  @Get()
  @ApiQuery({
    name: "accountId",
    description: "The ID of the account to retrieve holdings for.",
    type: String,
  })
  @ApiOperation({
    summary: "Get holdings for a specific account.",
    description: "Retrieves all holdings for the authenticated user within a specified account.",
  })
  @ApiOkResponse({ description: "Holdings found successfully.", type: [Holding] })
  async getHoldings(@CurrentUser() user: User, @Query("accountId") accountId: string) {
    const account = await Account.findOne({ where: { id: accountId, user: { id: user.id } } });
    if (!account) throw new NotFoundException(`Failed to find account with id ${accountId}`);
    return await Holding.find({ where: { account: { id: accountId } } });
  }

  @Get("history")
  @ApiOperation({
    summary: "Get holding history for a specific account.",
    description: "Retrieves holding history for the given account. This is useful for displaying the holdings value over time.",
  })
  @ApiQuery({
    name: "accountId",
    description: "The ID of the account to retrieve holding history for.",
    type: String,
  })
  @ApiOkResponse({ description: "Holding history found successfully.", type: [EntityHistory] })
  async getHoldingHistory(@CurrentUser() user: User, @Query("accountId") accountId: string) {
    const account = await Account.findOne({ where: { id: accountId, user: { id: user.id }, type: AccountType.investment } });
    if (!account) throw new NotFoundException(`Failed to find account with id ${accountId}`);
    return (await this.netWorthService.getHistoryForHoldings(account)).map((x) => x.history);
  }

  @Get("timeline/:id")
  @ApiOperation({
    summary: "Get timeline of a specific holding.",
    description: "Retrieves the value change over time of a holding given by it's ID.",
  })
  @ApiOkResponse({ description: "Holding over time successfully generated.", type: [HistoricalDataPoint] })
  async getHoldingTimeline(@Param("id") id: string, @CurrentUser() user: User) {
    const holding = await Holding.findOne({ where: { account: { user: { id: user.id } }, id } });
    if (holding == null) throw new NotFoundException();
    return (await this.holdingService.getTimelineForHolding(holding)).timeline();
  }

  @Get("live/major")
  @ApiOperation({
    summary: "Returns major holding prices.",
    description: "Retrieves the major holdings current ticker value and returns them. Calling this more than every 5 minutes will result in the same data.",
  })
  @ApiOkResponse({ description: "Successfully acquired major ticker prices.", type: [MarketIndexDto] })
  async getLive(@CurrentUser() _user: User) {
    return await this.holdingService.getMajorIndices();
  }

  @Get("live")
  @ApiOperation({
    summary: "Returns live prices for requested symbols.",
    description: "Retrieves the current ticker values for the provided symbols. Calling this for the same symbols within 5 minutes will return cached data.",
  })
  @ApiQuery({
    name: "symbols",
    required: true,
    description: "Comma-separated list of ticker symbols (e.g., AAPL,MSFT,TSLA)",
    type: String,
  })
  @ApiOkResponse({ description: "Successfully acquired live ticker prices.", type: [MarketIndexDto] })
  async getLivePrices(@CurrentUser() _user: User, @Query("symbols") symbols: string) {
    if (!symbols) throw new BadRequestException("You must provide at least one symbol in the query parameters.");
    // Convert the comma-separated string into an array of uppercase, trimmed strings
    const symbolArray = symbols.split(",").map((s) => s.trim().toUpperCase());
    return await this.holdingService.getLiveHoldingPrices(symbolArray);
  }
}
