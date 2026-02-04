import { Account } from "@backend/account/model/account.model";
import { EntityHistory } from "@backend/core/model/api/entity.history.dto";
import { HoldingHistory } from "@backend/holding/model/holding.history.model";
import { Injectable } from "@nestjs/common";
import { groupBy } from "lodash";

/**
 * This service provides holdings common functions
 */
@Injectable()
export class HoldingService {
  /** Generates the holding history, per holding, for all holdings of the given account */
  async getHistoryForAccount(account: Account) {
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
