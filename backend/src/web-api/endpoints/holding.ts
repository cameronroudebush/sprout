import { Account } from "@backend/model/account";
import { RestEndpoints } from "@backend/model/api/endpoint";
import { EntityHistory } from "@backend/model/api/entity.history";
import { RestBody } from "@backend/model/api/rest.request";
import { Holding } from "@backend/model/holding";
import { HoldingHistory } from "@backend/model/holding.history";
import { User } from "@backend/model/user";
import { groupBy } from "lodash";
import { RestMetadata } from "../metadata";

/** This class provides holding data via REST requests */
export class HoldingAPI {
  /** Returns the holdings for all accounts  */
  @RestMetadata.register(new RestMetadata(RestEndpoints.holding.get, "GET"))
  async getHoldings(_request: RestBody, user: User) {
    const holdings = await Holding.find({ where: { account: { user: { id: user.id } } } });
    return holdings;
  }

  /** Returns the holding values over time calculation of value */
  @RestMetadata.register(new RestMetadata(RestEndpoints.holding.getHistory, "GET"))
  async getHoldingOT(_request: RestBody, user: User) {
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
