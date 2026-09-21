import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { CurrencyHelper } from "@backend/core/model/utility/currency.helper.js";
import { TestEntities } from "@backend/test/entities.js";
import { ExchangeRateJob } from "@backend/core/jobs/exchange-rate.js";
import { instanceToPlain } from "class-transformer";

describe("CurrencyHelper", () => {
  const user = TestEntities.user;

  beforeEach(() => {
    vi.restoreAllMocks();
  });

  describe("format", () => {
    it("should format number into currency string using fallback when user is null", () => {
      const formatted = CurrencyHelper.format(1234.56, null as any);
      expect(formatted).toContain("1,234.56");
    });
  });

  describe("convert", () => {
    it("should return same value if source and target currency match", () => {
      const converted = CurrencyHelper.convert(100, "USD", "USD");
      expect(converted).toBe(100);
    });

    it("should return 0 when amount is null/0 or missing exchange rate", () => {
      expect(CurrencyHelper.convert(0, "USD", "EUR")).toBe(0);
      expect(CurrencyHelper.convert(null as any, "USD", "EUR")).toBe(0);

      ExchangeRateJob.exchangeRates = {};
      expect(CurrencyHelper.convert(100, "USD", "EUR")).toBe(0);
    });

    it("should convert amount when exchange rate exists", () => {
      ExchangeRateJob.exchangeRates = { USD: { EUR: 0.85 } };
      expect(CurrencyHelper.convert(100, "USD", "EUR")).toBe(85);
    });
  });

  describe("convertList", () => {
    it("should convert a list of objects in place", () => {
      ExchangeRateJob.exchangeRates = { EUR: { USD: 1.18 } };
      const items = [{ balance: 100, currency: "EUR" }];
      const converted = CurrencyHelper.convertList(items, "balance", "currency", user);
      expect(converted[0]!.balance).toBe(118);
    });
  });

  describe("ExposeCurrencyFields decorator", () => {
    it("should transform balance using user preferred currency and handle null balance", () => {
      vi.spyOn(CurrencyHelper, "ExposeCurrencyFields").mockRestore();

      class TestClass {
        balance!: number | null;
        currency!: string;

        constructor(balance?: number | null, currency?: string) {
          this.balance = balance === undefined ? 100 : balance;
          this.currency = currency ?? "EUR";
        }
      }

      CurrencyHelper.ExposeCurrencyFields<TestClass>("balance", "currency")(TestClass);

      ExchangeRateJob.exchangeRates = { EUR: { USD: 1.18 } };
      const instance = new TestClass(100, "EUR");

      const plain = instanceToPlain(instance, { context: { user } } as any);
      expect(plain.balance).toBe(118);

      const nullInstance = new TestClass(null, "EUR");
      const nullPlain = instanceToPlain(nullInstance, { context: { user } } as any);
      expect(nullPlain.balance).toBeNull();
    });
  });
});
