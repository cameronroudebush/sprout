import { setupTests } from "@backend/test/helpers";
setupTests();

import { Utility } from "@backend/core/model/utility/utility";

describe("Utility", () => {
  describe("shuffleArray", () => {
    it("should return a shuffled copy of the array", () => {
      const input = [1, 2, 3, 4, 5];
      const shuffled = Utility.shuffleArray(input);

      expect(shuffled).toHaveLength(input.length);
      expect(shuffled.sort()).toEqual(input.sort());
    });
  });
});
