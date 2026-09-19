import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { ProviderModule, ProviderSyncJobsProvider } from "@backend/providers/provider.module.js";

describe("ProviderModule", () => {
  it("should define module class and ProviderSyncJobsProvider factory", () => {
    expect(ProviderModule).toBeDefined();

    const mockProvider = {
      config: { dbType: "plaid" },
      rateLimit: vi.fn(),
      getAppConfiguration: vi.fn().mockReturnValue({ syncFrequency: "0 * * * *" }),
    } as any;
    const mockSyncService = {} as any;

    const jobs = (ProviderSyncJobsProvider as any).useFactory([mockProvider], mockSyncService);
    expect(jobs.length).toBe(1);
  });
});
