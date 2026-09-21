import { setupTests } from "@backend/test/helpers";
setupTests();

import { TotalNetWorthDTO } from "@backend/net-worth/model/api/total.dto";

describe("TotalNetWorthDTO", () => {
  it("should construct total net worth dto", () => {
    const dto = new TotalNetWorthDTO(15000, {} as any, []);

    expect(dto.value).toBe(15000);
    expect(dto.timeline).toEqual([]);
  });
});
