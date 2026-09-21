import { setupTests } from "@backend/test/helpers";
setupTests();

import { CategoryStats } from "@backend/category/model/api/category.stats.dto";

describe("CategoryStats", () => {
  it("should construct from plain object", () => {
    const dto = CategoryStats.fromPlain({
      categoryCount: { Rent: 1 },
      colorMapping: { Rent: "#FF0000" },
    });

    expect(dto.categoryCount).toEqual({ Rent: 1 });
    expect(dto.colorMapping).toEqual({ Rent: "#FF0000" });
  });
});
