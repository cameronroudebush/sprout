import { setupTests } from "@backend/test/helpers";
setupTests();

import { EntityHistory, EntityHistoryDataPoint, HistoricalDataPoint } from "@backend/net-worth/model/api/entity.history.dto";

describe("EntityHistory DTOs", () => {
  describe("EntityHistoryDataPoint", () => {
    it("should instantiate with valueChange, percentChange, start", () => {
      const date = new Date();
      const point = new EntityHistoryDataPoint(500, 5.0, date);

      expect(point.valueChange).toBe(500);
      expect(point.percentChange).toBe(5.0);
      expect(point.start).toBe(date);
    });
  });

  describe("HistoricalDataPoint", () => {
    it("should instantiate with date and value", () => {
      const date = new Date();
      const point = new HistoricalDataPoint(date, 10000);

      expect(point.date).toBe(date);
      expect(point.value).toBe(10000);
    });
  });

  describe("EntityHistory", () => {
    it("should aggregate data points for all timeframes", () => {
      const dp = new EntityHistoryDataPoint(100, 1.0, new Date());
      const history = new EntityHistory(dp, dp, dp, dp, dp, dp, dp);

      expect(history.last1Day).toBe(dp);
      expect(history.allTime).toBe(dp);
    });

    it("should generate plain zeroed EntityHistory via static plain getter", () => {
      const plain = EntityHistory.plain;
      expect(plain.last1Day.valueChange).toBe(0);
      expect(plain.last1Day.percentChange).toBe(0);
    });
  });
});
