import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { ManualSyncDto } from "@backend/providers/model/manual.sync.dto.js";

describe("ManualSyncDto", () => {
  it("should create default ManualSyncDto instance", () => {
    const dto = new ManualSyncDto();
    expect(dto.force).toBe(false);
  });
});
