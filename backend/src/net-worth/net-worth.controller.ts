import { Account } from "@backend/account/model/account.model";
import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { TotalNetWorthDTO } from "@backend/net-worth/model/api/total.dto";
import { NetWorthService } from "@backend/net-worth/net-worth.service";
import { User } from "@backend/user/model/user.model";
import { Controller, Get, NotFoundException, Param } from "@nestjs/common";
import { ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";
import { EntityHistory, HistoricalDataPoint } from "./model/api/entity.history.dto";

/** This controller contains information about net worth over time for the current user. */
@Controller("net-worth")
@ApiTags("Net Worth")
@AuthGuard.attach()
export class NetWorthController {
  constructor(private readonly netWorthService: NetWorthService) {}

  @Get("total")
  @ApiOperation({
    summary: "Retrieves the historical net-worth data for all accounts.",
    description: "Retrieves all data related to the overarching accounts and how they performed over time.",
  })
  @ApiOkResponse({ description: "Net worth over time successfully.", type: TotalNetWorthDTO })
  async getNetWorthTotal(@CurrentUser() user: User) {
    const total = await this.netWorthService.getTotalSummary(user);
    // Generate the content over time
    const calc = await this.netWorthService.getNetWorthSummary(user);
    return new TotalNetWorthDTO(total, calc.history, calc.timeline());
  }

  @Get("accounts")
  @ApiOperation({
    summary: "Get net worth by ALL accounts represented as time frames.",
    description: "Retrieves the net worth overtime of each account associated to the current user. Does not include any timeline data.",
  })
  @ApiOkResponse({ description: "Net worth over time successfully.", type: [EntityHistory] })
  async getNetWorthByAccounts(@CurrentUser() user: User) {
    return (await this.netWorthService.getNetWorthByAccounts(user)).map((x) => x.history);
  }

  @Get("timeline/account/:id")
  @ApiOperation({
    summary: "Get net worth over time (timeline) of a specific account.",
    description: "Retrieves the net worth overtime for the specific given account",
  })
  @ApiOkResponse({ description: "Net worth over time successfully generated.", type: [HistoricalDataPoint] })
  async getNetWorthTimelineAccount(@Param("id") id: string, @CurrentUser() user: User) {
    const account = await Account.findOne({ where: { user: { id: user.id }, id } });
    if (account == null) throw new NotFoundException();
    return (await this.netWorthService.getNetWorthByAccount(user, account)).timeline();
  }
}
