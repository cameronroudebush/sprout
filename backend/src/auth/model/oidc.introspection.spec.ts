import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it, vi } from "vitest";

setupTests();

import { Configuration } from "@backend/config/core.js";
import { UnauthorizedException } from "@nestjs/common";
import { OIDCIDTokenIntrospectionResult, OIDCIntrospectionResult } from "./oidc.introspection.js";

describe("OIDCIntrospection", () => {
  it("should check expiration and client state", () => {
    const res = new OIDCIntrospectionResult();
    res.expiresAt = Math.floor(Date.now() / 1000) - 100;
    res.clientId = "client-123";

    expect(res.isExpired).toBe(true);

    Configuration.server.auth.oidc.clientId = "client-123";
    expect(() => res.checkIssuedState()).not.toThrow();

    res.clientId = "wrong-client";
    expect(() => res.checkIssuedState()).toThrow(UnauthorizedException);

    const logger = { debug: vi.fn() } as any;
    res.logExpirationDate("Test", logger);
    expect(logger.debug).toHaveBeenCalled();
  });

  it("should validate ID Token introspection result", () => {
    const idTokenRes = new OIDCIDTokenIntrospectionResult();
    idTokenRes.issuer = "https://issuer.com";
    idTokenRes.authorizedParty = "client-123";

    Configuration.server.auth.oidc.issuer = "https://issuer.com";
    Configuration.server.auth.oidc.clientId = "client-123";

    expect(() => idTokenRes.checkIssuedState()).not.toThrow();

    idTokenRes.issuer = "wrong-issuer";
    expect(() => idTokenRes.checkIssuedState()).toThrow(new UnauthorizedException("Invalid token issuer."));
  });

  it("should throw UnauthorizedException when authorizedParty does not match clientId", () => {
    const idTokenRes = new OIDCIDTokenIntrospectionResult();
    idTokenRes.issuer = "https://issuer.com";
    idTokenRes.authorizedParty = "wrong-client";

    Configuration.server.auth.oidc.issuer = "https://issuer.com";
    Configuration.server.auth.oidc.clientId = "client-123";

    expect(() => idTokenRes.checkIssuedState()).toThrow(new UnauthorizedException("Invalid token audience."));
  });
});
