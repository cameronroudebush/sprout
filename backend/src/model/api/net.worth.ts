import { Base } from "@backend/model/base";
import { Dictionary } from "lodash";

export class NetWorthOverTime extends Base {
  last1Day?: number;
  last7Days?: number;
  last30Days?: number;
  lastYear?: number;
  historicalData: Dictionary<number>;

  /** Some net worth OT data may contain an account Id */
  accountId?: string;

  constructor(last1Day: number, last7Days: number, last30Days: number, lastYear: number, historicalData: Dictionary<number>) {
    super();
    this.last1Day = last1Day;
    this.last7Days = last7Days;
    this.last30Days = last30Days;
    this.lastYear = lastYear;
    this.historicalData = historicalData;
  }
}
