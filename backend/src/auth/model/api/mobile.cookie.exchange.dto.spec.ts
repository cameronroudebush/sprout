import { setupTests } from "@backend/test/helpers";
setupTests();

import { MobileTokenExchangeDto } from "@backend/auth/model/api/mobile.cookie.exchange.dto";

describe("MobileTokenExchangeDto", () => {
  it("should construct mobile cookie exchange payload", () => {
    const dto = new MobileTokenExchangeDto("auth-code-123", "verifier-hash");

    expect(dto.code).toBe("auth-code-123");
    expect(dto.appVerifier).toBe("verifier-hash");
  });
});
