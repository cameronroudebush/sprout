import { Account } from "@backend/account/model/account.model";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { AuthGuard } from "@backend/core/guard/auth.guard";
import { EntityHistory } from "@backend/core/model/api/entity.history.dto";
import { HoldingHistory } from "@backend/holding/model/holding.history.model";
import { Holding } from "@backend/holding/model/holding.model";
import { User } from "@backend/user/model/user.model";
import { Controller, Get } from "@nestjs/common";
import { ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";
import { groupBy } from "lodash";

/** This controller contains information about {@link Holding} models which is stock information. */
@Controller("holding")
@ApiTags("Holding")
@AuthGuard.attach()
export class HoldingController {
  @Get()
  @ApiOperation({
    summary: "Get holdings.",
    description: "Retrieves all holdings for the authenticated user.",
  })
  @ApiOkResponse({ description: "Holdings found successfully.", type: [Holding] })
  async getHoldings(@CurrentUser() user: User) {
    return await Holding.find({ where: { account: { user: { id: user.id } } } });
  }

  @Get("history")
  @ApiOperation({
    summary: "Get holding history.",
    description: "Retrieves holding history for all available holdings of the current user. This is useful for displaying the holdings value over time.",
  })
  @ApiOkResponse({ description: "Holding history found successfully.", type: Object })
  async getHoldingHistory(@CurrentUser() user: User) {
    // Accounts that have holdings
    const accounts = await Account.find({ where: { user: { id: user.id }, type: "investment" } });
    const historyByAcc = await Promise.all(
      accounts.map(async (a) => {
        const hist = await HoldingHistory.getHistoryForAccount(a);
        const groupedHistory = groupBy(hist, "holding.id");
        const l = Object.keys(groupedHistory).map((holdingId) => {
          const holdingHistory = groupedHistory[holdingId]!;
          const ot = EntityHistory.getForHistory(HoldingHistory, holdingHistory);
          ot.connectedId = holdingId;
          return ot;
        });
        return { [a.id]: l };
      }),
    );
    // Merge all the account-specific holding histories into a single object
    return historyByAcc.reduce((acc, current) => {
      return { ...acc, ...current };
    }, {});
  }
}
