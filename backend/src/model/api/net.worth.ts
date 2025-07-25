import { Base } from "@backend/model/base";
import { Dictionary } from "lodash";

/** This class represents a time frame of net worth change. */
export class NetWorthFrameData extends Base {
  percentChange?: number;
  valueChange: number;

  constructor(valueChange: number, percentChange?: number) {
    super();
    this.valueChange = valueChange;
    this.percentChange = percentChange;
  }
}

/** This class represents the net worth over time of the entire portfolio or of an account if accountId is specified. */
export class NetWorthOverTime extends Base {
  last1Day: NetWorthFrameData;
  last7Days: NetWorthFrameData;
  last30Days: NetWorthFrameData;
  lastYear: NetWorthFrameData;
  historicalData: Dictionary<number>;

  /** Some net worth OT data may contain an account Id */
  accountId?: string;

  constructor(
    last1Day: NetWorthFrameData,
    last7Days: NetWorthFrameData,
    last30Days: NetWorthFrameData,
    lastYear: NetWorthFrameData,
    historicalData: Dictionary<number>,
  ) {
    super();
    this.last1Day = last1Day;
    this.last7Days = last7Days;
    this.last30Days = last30Days;
    this.lastYear = lastYear;
    this.historicalData = historicalData;
  }
}
