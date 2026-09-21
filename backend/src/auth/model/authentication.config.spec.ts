import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it } from "vitest";

setupTests();

import { AuthenticationConfig } from "./authentication.config.js";

describe("AuthenticationConfig", () => {
  it("should initialize default values and oidc config", () => {
    const config = new AuthenticationConfig();
    expect(config.type).toBe("local");
    expect(config.secretKey).toBeDefined();

    const oidc = config.oidc;
    expect(oidc.allowNewUsers).toBe(true);
    expect(oidc.scopes).toContain("openid");

    oidc.issuer = "https://issuer.com";
    oidc.clientId = "client-id";
    oidc.secret = "secret";
    expect(() => oidc.validate()).not.toThrow();
    expect(oidc.authHeader).toBe(Buffer.from("client-id:secret").toString("base64"));
  });

  it("should throw error if oidc config is invalid", () => {
    const config = new AuthenticationConfig();
    expect(() => config.oidc.validate()).toThrow("Issuer URL is required for OIDC usage.");

    config.oidc.issuer = "https://issuer.com";
    expect(() => config.oidc.validate()).toThrow("Client ID is required for OIDC usage.");

    config.oidc.clientId = "client-id";
    expect(() => config.oidc.validate()).toThrow("Secret is required for OIDC usage.");
  });
});
