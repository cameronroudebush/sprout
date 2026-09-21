import { setupTests } from "@backend/test/helpers";
setupTests();

import { DailySpendingCalendarResponseDTO, DailySpendingItem } from "@backend/cash-flow/model/api/daily.spending.dto";

describe("DailySpendingDTOs", () => {
  describe("DailySpendingItem", () => {
    it("should instantiate with day and amount", () => {
      const item = new DailySpendingItem(15, -42.5);
      expect(item.day).toBe(15);
      expect(item.amount).toBe(-42.5);
    });
  });

  describe("DailySpendingCalendarResponseDTO", () => {
    it("should instantiate with array of DailySpendingItem", () => {
      const item = new DailySpendingItem(1, 100);
      const dto = new DailySpendingCalendarResponseDTO([item]);

      expect(dto.spending).toHaveLength(1);
      expect(dto.spending[0]).toBe(item);
    });
  });
});
