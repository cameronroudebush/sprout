import { setupTests } from "@backend/test/helpers";
setupTests();

import { APIConfig, TileConfig } from "@backend/config/model/api/configuration.dto";

describe("APIConfig DTO", () => {
  it("should construct api configuration dto", () => {
    const tiles = new TileConfig("light-url", "dark-url");
    const dto = new APIConfig(true, true, tiles, "bf-123");

    expect(dto.chatEnabled).toBe(true);
    expect(dto.emailEnabled).toBe(true);
    expect(dto.tiles).toBe(tiles);
    expect(dto.brandFetchClientId).toBe("bf-123");
  });
});
