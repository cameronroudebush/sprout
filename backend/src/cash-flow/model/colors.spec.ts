import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { Colors } from "@backend/cash-flow/model/colors.js";

describe("Colors", () => {
  beforeEach(() => {
    Colors.resetFeatureColors();
  });

  describe("getColorForFeature", () => {
    it("should return a consistent color hex string for any feature string", () => {
      const color1 = Colors.getColorForFeature("Groceries");
      const color2 = Colors.getColorForFeature("Groceries");
      const color3 = Colors.getColorForFeature("Utilities");

      expect(color1).toBe(color2);
      expect(color1).toMatch(/^#[0-9A-F]{6}$/i);
      expect(typeof color3).toBe("string");
    });

    it("should wrap around colors array when features exceed color count", () => {
      for (let i = 0; i < Colors.colors.length + 5; i++) {
        Colors.getColorForFeature(`Feature_${i}`);
      }
      expect(Colors.getColorForFeature(`Feature_${Colors.colors.length}`)).toBe(Colors.colors[0]);
    });

    it("should reset feature colors", () => {
      const c1 = Colors.getColorForFeature("Test");
      Colors.resetFeatureColors();
      const c2 = Colors.getColorForFeature("Test");
      expect(c1).toBe(c2);
    });

    it("should skip colors excluded by the consuming surface", () => {
      const excluded = Colors.colors[0]!;

      expect(Colors.getColorForFeature("ChatChart", [excluded])).not.toBe(excluded);
    });
  });
});
