import { Base } from "@backend/model/base";
import { Dictionary } from "lodash";

export class NetWorthOverTime extends Base {
  last7Days: number;
  last30Days: number;
  lastYear: number;
  historicalData: Dictionary<number>;

  constructor(last7Days: number, last30Days: number, lastYear: number, historicalData: Dictionary<number>) {
    super();
    this.last7Days = last7Days;
    this.last30Days = last30Days;
    this.lastYear = lastYear;
    this.historicalData = historicalData;
  }
}
