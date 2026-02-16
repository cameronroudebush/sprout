import { EntityHistory, HistoricalDataPoint } from "@backend/net-worth/model/api/entity.history.dto";

/** This class expresses the content for our overarching accounts of net worth over time including a timeline, current value, and history. */
export class TotalNetWorthDTO {
  value: number;
  history: EntityHistory;
  timeline: HistoricalDataPoint[];

  constructor(value: number, history: EntityHistory, timeline: HistoricalDataPoint[]) {
    this.value = value;
    this.history = history;
    this.timeline = timeline;
  }
}
