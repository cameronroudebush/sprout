import { setupTests } from "@backend/test/helpers";
setupTests();

import { ColumnNumericTransformer } from "@backend/database/transformers/numeric";

describe("ColumnNumericTransformer", () => {
  let transformer: ColumnNumericTransformer;

  beforeEach(() => {
    transformer = new ColumnNumericTransformer();
  });

  describe("to / from", () => {
    it("should return string or value in to", () => {
      expect(transformer.to(100.5)).toBe(100.5);
    });

    it("should parse float in from", () => {
      expect(transformer.from("123.45")).toBe(123.45);
    });
  });
});
