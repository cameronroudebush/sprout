import { setupTests } from "@backend/test/helpers";
setupTests();

import { ExchangeRateJob } from "@backend/core/jobs/exchange-rate";

describe("ExchangeRateJob", () => {
  let job: ExchangeRateJob;
  let cacheManager: any;
  let configService: any;

  beforeEach(() => {
    jest.clearAllMocks();
    cacheManager = {
      get: jest.fn(),
      set: jest.fn().mockResolvedValue(undefined),
    };
    configService = {
      convertCronToMilliseconds: jest.fn().mockResolvedValue(3600000),
    };
    job = new ExchangeRateJob(configService, cacheManager);
  });

  describe("update", () => {
    it("should update rates from L2 cache if available", async () => {
      const cachedRates = { USD: { EUR: 0.85 } };
      cacheManager.get.mockResolvedValue(cachedRates);

      await (job as any).update();

      expect(cacheManager.get).toHaveBeenCalledWith(ExchangeRateJob.CACHE_KEY);
      expect(ExchangeRateJob.exchangeRates).toEqual(cachedRates);
    });

    it("should refresh rates from Yahoo Finance if cache is empty", async () => {
      cacheManager.get.mockResolvedValue(null);
      const refreshSpy = jest.spyOn(job, "refreshExchangeRates").mockResolvedValue(undefined);

      await (job as any).update();

      expect(refreshSpy).toHaveBeenCalled();
    });
  });
});
