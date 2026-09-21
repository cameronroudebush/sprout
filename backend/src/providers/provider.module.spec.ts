import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { ProviderModule, ProviderSyncJobsProvider } from "@backend/providers/provider.module.js";
import { PROVIDER_LIST_TOKEN } from "@backend/providers/model/constants.js";

describe("ProviderSyncJobsProvider and ProviderModule", () => {
  it("should create sync jobs for each provider in the factory", () => {
    const mockProvider1 = {
      config: { dbType: "plaid" },
      getAppConfiguration: () => ({ syncFrequency: "0 0 * * *", enabled: true }),
    } as any;
    const mockProvider2 = {
      config: { dbType: "zillow" },
      getAppConfiguration: () => ({ syncFrequency: "0 0 * * *", enabled: true }),
    } as any;
    const mockSyncService = {} as any;

    const jobs = ProviderSyncJobsProvider.useFactory([mockProvider1, mockProvider2], mockSyncService);

    expect(jobs).toHaveLength(2);
  });

  it("should test PROVIDER_LIST_TOKEN factory provider", () => {
    const moduleMetadata = Reflect.getMetadata("providers", ProviderModule);
    const providerListProvider = moduleMetadata.find((p: any) => p.provide === PROVIDER_LIST_TOKEN);

    expect(providerListProvider).toBeDefined();
    const instances = providerListProvider.useFactory("inst1", "inst2");
    expect(instances).toEqual(["inst1", "inst2"]);
  });
});
