import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it } from "vitest";

setupTests();

import { ConfigurationMetadata } from "./configuration.metadata.js";

class TestConfig {
  @ConfigurationMetadata.assign({ comment: "Test comment", restrictedValues: [1, 2] })
  val = 1;
}

describe("ConfigurationMetadata", () => {
  it("should assign metadata to properties using reflect-metadata", () => {
    const config = new TestConfig();
    const meta = Reflect.getMetadata(ConfigurationMetadata.METADATA_KEY, config, "val");
    expect(meta).toBeDefined();
    expect(meta.comment).toBe("Test comment");
    expect(meta.restrictedValues).toEqual([1, 2]);
  });
});
