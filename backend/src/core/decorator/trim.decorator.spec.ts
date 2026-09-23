import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { Trim } from "./trim.decorator.js";
import { plainToInstance } from "class-transformer";

describe("Trim", () => {
  it("should trim string values and preserve nullish values", () => {
    class Input {
      value!: string | undefined;
    }
    Trim()(Input.prototype, "value");

    expect(plainToInstance(Input, { value: "  value  " }).value).toBe("value");
    expect(plainToInstance(Input, { value: undefined }).value).toBeUndefined();
  });
});
