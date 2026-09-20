import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it, vi } from "vitest";

setupTests();

import { ExchangeRateJob } from "./exchange-rate.js";

describe("ExchangeRateJob", () => {
  it("should update exchange rates from cache or yahoo finance", async () => {
    const configService = { convertCronToMilliseconds: vi.fn().mockResolvedValue(60000) } as any;
    const cacheManager = { get: vi.fn().mockResolvedValue(null), set: vi.fn().mockResolvedValue(undefined) } as any;

    const job = new ExchangeRateJob(configService, cacheManager);
    vi.spyOn(job as any, "refreshExchangeRates").mockResolvedValue(undefined);

    await job["update"]();
    expect((job as any).refreshExchangeRates).toHaveBeenCalled();
  });
});
