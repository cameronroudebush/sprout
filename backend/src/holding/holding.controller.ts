import { Account } from "@backend/account/model/account.model";
import { AccountType } from "@backend/account/model/account.type";
import { AuthGuard } from "@backend/auth/auth.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { EntityHistory } from "@backend/core/model/api/entity.history.dto";
import { HoldingHistory } from "@backend/holding/model/holding.history.model";
import { Holding } from "@backend/holding/model/holding.model";
import { User } from "@backend/user/model/user.model";
import { Controller, Get, NotFoundException, Query } from "@nestjs/common";
import { ApiOkResponse, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { groupBy } from "lodash";

/** This controller contains information about {@link Holding} models which is stock information. */
@Controller("holding")
@ApiTags("Holding")
@AuthGuard.attach()
export class HoldingController {
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
    const hist = await HoldingHistory.getHistoryForAccount(account);
    const groupedHistory = groupBy(hist, "holding.id");
    return Object.keys(groupedHistory).map((holdingId) => {
      const holdingHistory = groupedHistory[holdingId]!;
      const ot = EntityHistory.getForHistory(HoldingHistory, holdingHistory);
      ot.connectedId = holdingId;
      return ot;
    });
  }
}
