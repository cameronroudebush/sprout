import { setupTests } from "@backend/test/helpers";
setupTests();

import { Base } from "@backend/core/model/base";

class TestBase extends Base {
  name!: string;
}

describe("Base model", () => {
  it("should create instance from plain object", () => {
    const obj = TestBase.fromPlain({ name: "Sample" });
    expect(obj.name).toBe("Sample");
  });
});
