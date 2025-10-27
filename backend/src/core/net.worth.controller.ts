import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { AuthGuard } from "@backend/core/guard/auth.guard";
import { EntityHistory } from "@backend/core/model/api/entity.history.dto";
import { User } from "@backend/user/model/user.model";
import { Controller, Get } from "@nestjs/common";
import { ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";
import { groupBy } from "lodash";

/** This controller contains information about net worth over time for the current user. */
@Controller("net-worth")
@ApiTags("Net Worth")
@AuthGuard.attach()
export class NetWorthController {
  @Get()
  @ApiOperation({
    summary: "Get net worth.",
    description: "Retrieves the current net worth for the authenticated user.",
  })
  @ApiOkResponse({ description: "Net worth calculated successfully.", schema: { type: "number", format: "double" } })
  async getNetWorth(@CurrentUser() user: User) {
    // Calculate net worth from all accounts
    const accounts = await Account.find({ where: { user: { id: user.id } } });
    return accounts.reduce((acc, account) => acc + account.balance, 0);
  }

  @Get("ot")
  @ApiOperation({
    summary: "Get net worth.",
    description: "Retrieves the net worth overtime of the current user. Useful for displaying in a chart.",
  })
  @ApiOkResponse({ description: "Net worth over time successfully.", type: EntityHistory })
  async getNetWorthOT(@CurrentUser() user: User) {
    const accountHistory = await AccountHistory.getHistoryForUser(user);
    return EntityHistory.getForHistory(AccountHistory, accountHistory);
  }

  @Get("account")
  @ApiOperation({
    summary: "Get net worth by accounts.",
    description: "Retrieves the net worth overtime of each account associated to the current user. Useful for displaying in a chart.",
  })
  @ApiOkResponse({ description: "Net worth over time successfully.", type: [EntityHistory] })
  async getNetWorthByAccounts(@CurrentUser() user: User) {
    const accounts = await Account.getForUser(user);
    const accountHistory = await AccountHistory.getHistoryForUser(user);
    const groupedAccounts = groupBy(accountHistory, "account.id");
    // Loop over each account
    return Object.keys(groupedAccounts).map((accountId) => {
      const account = accounts.find((x) => x.id === accountId);
      const accountHistory = groupedAccounts[accountId]!;
      const ot = EntityHistory.getForHistory(AccountHistory, accountHistory, account);
      ot.connectedId = accountId;
      return ot;
    });
  }
}
