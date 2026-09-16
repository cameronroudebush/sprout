import { setupTests } from "@backend/test/helpers";
setupTests();

import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { TestEntities } from "@backend/test/entities";

describe("CurrencyHelper", () => {
  const user = TestEntities.user;

  describe("format", () => {
    it("should format number into currency string", () => {
      const formatted = CurrencyHelper.format(1234.56, user);
      expect(formatted).toContain("1,234.56");
    });
  });

  describe("convert", () => {
    it("should return same value if source and target currency match", async () => {
      const converted = await CurrencyHelper.convert(100, "USD", "USD");
      expect(converted).toBe(100);
    });
  });
});
