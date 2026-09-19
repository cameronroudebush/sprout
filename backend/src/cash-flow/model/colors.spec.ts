import { setupTests } from "@backend/test/helpers";
setupTests();

import { Colors } from "@backend/cash-flow/model/colors";

describe("Colors", () => {
  describe("getColorForFeature", () => {
    it("should return a consistent color hex string for any feature string", () => {
      const color1 = Colors.getColorForFeature("Groceries");
      const color2 = Colors.getColorForFeature("Groceries");
      const color3 = Colors.getColorForFeature("Utilities");

      expect(color1).toBe(color2);
      expect(color1).toMatch(/^#[0-9A-F]{6}$/i);
      expect(typeof color3).toBe("string");
    });
  });
});
