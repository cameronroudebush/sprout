import { setupTests } from "@backend/test/helpers";
setupTests();

import { MajorIndexTimelineDto } from "@backend/holding/model/api/major.index.timeline.dto";

describe("MajorIndexTimelineDto", () => {
  it("should construct with timeline points", () => {
    const points = [{ date: new Date(), value: 5000, changePercent: 0.2 }];
    const dto = new MajorIndexTimelineDto({
      symbol: "^GSPC",
      name: "S&P 500",
      color: "#2196F3",
      timeline: points,
    });

    expect(dto.symbol).toBe("^GSPC");
    expect(dto.name).toBe("S&P 500");
    expect(dto.timeline).toBe(points);
  });
});
