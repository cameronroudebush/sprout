import { setupTests } from "@backend/test/helpers";
setupTests();

import { UnsecureAppConfiguration } from "@backend/config/model/api/unsecure.app.config.dto";

describe("UnsecureAppConfiguration DTO", () => {
  it("should construct unsecure app configuration dto", () => {
    const dto = new UnsecureAppConfiguration("1.0.0", "local", true);

    expect(dto.version).toBe("1.0.0");
    expect(dto.authMode).toBe("local");
    expect(dto.allowUserCreation).toBe(true);
  });
});
