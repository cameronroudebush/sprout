import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { MajorIndexTimelineDto, MajorIndexTimelinePoint } from "@backend/holding/model/api/major.index.timeline.dto.js";

describe("MajorIndexTimelineDto", () => {
  it("should instantiate MajorIndexTimelinePoint", () => {
    const d = new Date();
    const point = new MajorIndexTimelinePoint({ date: d, value: 5000, changePercent: 1.2 });
    expect(point.date).toBe(d);
    expect(point.value).toBe(5000);
    expect(point.changePercent).toBe(1.2);
  });

  it("should instantiate MajorIndexTimelineDto", () => {
    const dto = new MajorIndexTimelineDto({
      symbol: "^GSPC",
      name: "S&P 500",
      color: "#2196F3",
      timeline: [],
    });
    expect(dto.symbol).toBe("^GSPC");
    expect(dto.name).toBe("S&P 500");
    expect(dto.color).toBe("#2196F3");
    expect(dto.timeline).toEqual([]);
  });
});
