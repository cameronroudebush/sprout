import { setupTests } from "@backend/test/helpers";
setupTests();

jest.mock("@backend/core/openapi", () => ({
  setupOpenApiHelp: jest.fn(),
}));

import { startupServer } from "@backend/server";

describe("server.ts", () => {
  it("should define startupServer function", () => {
    expect(startupServer).toBeDefined();
  });
});
