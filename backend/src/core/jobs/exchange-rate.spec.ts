import { setupTests } from "@backend/test/helpers";
setupTests();

import { ExchangeRateJob } from "@backend/core/jobs/exchange-rate";

describe("ExchangeRateJob", () => {
  let runner: ExchangeRateJob;

  beforeEach(() => {
    jest.clearAllMocks();
    runner = new ExchangeRateJob({} as any, {} as any);
  });

  describe("job", () => {
    it("should instantiate job runner", () => {
      expect(runner).toBeDefined();
    });
  });
});
