import { setupTests } from "@backend/test/helpers";
setupTests();

import { ChartRange } from "@backend/user/model/chart.range.model";
import { CurrencyOptions, EmailUpdateFrequency, UserConfig } from "@backend/user/model/user.config.model";

describe("UserConfig model", () => {
  it("should create instance with constructor arguments", () => {
    const config = new UserConfig(true, ChartRange.oneMonth, true, true, true);

    expect(config.privateMode).toBe(true);
    expect(config.netWorthRange).toBe(ChartRange.oneMonth);
    expect(config.secureMode).toBe(true);
    expect(config.allowWidgets).toBe(true);
    expect(config.includeAICapabilities).toBe(true);
    expect(config.emailUpdateFrequency).toBe(EmailUpdateFrequency.NONE);
    expect(config.currency).toBe(CurrencyOptions.USD);
  });
});
