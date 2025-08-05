import { EntityHistory } from "@backend/model/api/entity.history";
import { Holding } from "@backend/model/holding";

/** Represents a holding with value over time */
export class HoldingStats {
  holding: Holding;
  overTime?: EntityHistory;

  constructor(holding: Holding, overTime?: EntityHistory) {
    this.holding = holding;
    this.overTime = overTime;
  }
}
