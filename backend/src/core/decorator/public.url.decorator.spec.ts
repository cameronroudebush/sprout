import { setupTests } from "@backend/test/helpers";
setupTests();

import { PublicURL } from "@backend/core/decorator/public.url.decorator";

describe("PublicURL decorator", () => {
  it("should define PublicURL decorator", () => {
    expect(PublicURL).toBeDefined();
  });
});
