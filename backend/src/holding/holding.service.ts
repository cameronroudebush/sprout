import { Account } from "@backend/account/model/account.model";
import { Holding } from "@backend/holding/model/holding.model";
import { EntityHistory } from "@backend/net-worth/model/api/entity.history.dto";
import { NetWorthService } from "@backend/net-worth/net-worth.service";
import { Injectable } from "@nestjs/common";

/**
 * This service provides holdings common functions
 */
@Injectable()
export class HoldingService {
  constructor(private readonly netWorthService: NetWorthService) {}

  /** Generates the holding history, per holding, for all holdings of the given account. Does not include timeline */
  async getHistoryForAccount(account: Account): Promise<EntityHistory[]> {
    return (await this.netWorthService.getHistoryForHoldings(account)).map((x) => x.history);
  }

  /** Generates the holding history for an individual holding, only including the timeline. */
  async getTimelineForHolding(holding: Holding) {
    return await this.netWorthService.getHistoryForHolding(holding);
  }
}
