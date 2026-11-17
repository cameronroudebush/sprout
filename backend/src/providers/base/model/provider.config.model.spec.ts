import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { ProviderConfig } from "@backend/providers/base/model/provider.config.model.js";
import { ProviderCredentialsMode } from "@backend/providers/base/model/provider.credential.type.js";
import { ProviderSubType, ProviderType } from "@backend/providers/base/provider.type.js";

describe("ProviderConfig", () => {
  it("defaults credentials to system mode and accepts user mode", () => {
    const systemConfig = new ProviderConfig("Zillow", ProviderType.zillow, ProviderSubType.realEstate, "https://www.zillow.com");
    const userConfig = new ProviderConfig(
      "SimpleFIN",
      ProviderType.simpleFin,
      ProviderSubType.bankingInvestments,
      "https://www.simplefin.org/",
      undefined,
      ProviderCredentialsMode.USER,
    );

    expect(systemConfig.credentialsMode).toBe(ProviderCredentialsMode.SYSTEM);
    expect(userConfig.credentialsMode).toBe(ProviderCredentialsMode.USER);
  });
});
