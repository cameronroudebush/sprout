import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it, vi } from "vitest";

setupTests();

import { CONFIGURATION_REQUIREMENTS } from "./config.requirement.js";
import { Configuration } from "@backend/config/core.js";
import { BaseProviderConfig } from "@backend/providers/base/config.js";

describe("CONFIGURATION_REQUIREMENTS", () => {
  it("should validate and execute fix handlers for all configuration requirements", () => {
    const logger = { error: vi.fn(), warn: vi.fn() } as any;

    for (const req of CONFIGURATION_REQUIREMENTS) {
      expect(req.name).toBeDefined();
      const isValid = req.validate();
      expect(typeof isValid).toBe("boolean");
      req.fix(logger);
    }
  });

  it("should enforce encryption key requirement validation", () => {
    const keyReq = CONFIGURATION_REQUIREMENTS.find((r) => r.name.includes("Encryption Key"))!;
    const logger = { error: vi.fn() } as any;

    Configuration.encryptionKey = "66c60231a85abcf9fa2c6c07fd0b075c50c4a313585afb447c95838ecc6170d8";
    expect(keyReq.validate()).toBe(true);

    Configuration.encryptionKey = "short";
    expect(keyReq.validate()).toBe(false);
    keyReq.fix(logger);
    expect(logger.error).toHaveBeenCalled();
  });

  it("should enforce publicUrl presence check requirement", () => {
    const urlReq = CONFIGURATION_REQUIREMENTS.find((r) => r.name.includes("Public Application URL"))!;
    const logger = { warn: vi.fn() } as any;

    Configuration.server.publicUrl = "https://sprout.local";
    expect(urlReq.validate()).toBe(true);

    Configuration.server.publicUrl = "";
    expect(urlReq.validate()).toBe(false);
    urlReq.fix(logger);
    expect(logger.warn).toHaveBeenCalled();
  });

  it("should enforce Demo Mode Auth, Provider, and Job restrictions", () => {
    const authReq = CONFIGURATION_REQUIREMENTS.find((r) => r.name.includes("Demo Mode Auth"))!;
    const providerReq = CONFIGURATION_REQUIREMENTS.find((r) => r.name.includes("Demo Mode Provider"))!;
    const jobReq = CONFIGURATION_REQUIREMENTS.find((r) => r.name.includes("Demo Mode Job"))!;
    const logger = { error: vi.fn(), warn: vi.fn() } as any;

    Configuration.isDemoMode = true;
    (Configuration.server.auth as any).type = "oidc";

    expect(authReq.validate()).toBe(false);
    authReq.fix(logger);
    expect(Configuration.server.auth.type).toBe("local");

    // Provider check
    const mockProvider = new BaseProviderConfig();
    mockProvider.enabled = true;
    (Configuration.providers as any).plaid = mockProvider;

    expect(providerReq.validate()).toBe(false);
    providerReq.fix(logger);
    expect(mockProvider.enabled).toBe(false);

    // Job check
    Configuration.database.backup.enabled = true;
    Configuration.transaction.stuckTransactions.enabled = true;
    Configuration.user.deviceCheck.enabled = true;
    Configuration.server.email.enabled = true;
    Configuration.providers.syncNotifications.enabled = true;
    expect(jobReq.validate()).toBe(false);
    jobReq.fix(logger);
    expect(Configuration.database.backup.enabled).toBe(false);
    expect(Configuration.transaction.stuckTransactions.enabled).toBe(false);
    expect(Configuration.user.deviceCheck.enabled).toBe(false);
    expect(Configuration.server.email.enabled).toBe(false);
    expect(Configuration.providers.syncNotifications.enabled).toBe(false);
  });

  it("should pass demo mode job restrictions when every job is disabled", () => {
    const jobReq = CONFIGURATION_REQUIREMENTS.find((r) => r.name.includes("Demo Mode Job"))!;

    Configuration.isDemoMode = true;
    Configuration.database.backup.enabled = false;
    Configuration.transaction.stuckTransactions.enabled = false;
    Configuration.user.deviceCheck.enabled = false;
    Configuration.server.email.enabled = false;
    Configuration.providers.syncNotifications.enabled = false;

    expect(jobReq.validate()).toBe(true);
  });

  it("should not warn about demo mode jobs that are already disabled", () => {
    const jobReq = CONFIGURATION_REQUIREMENTS.find((r) => r.name.includes("Demo Mode Job"))!;
    const logger = { warn: vi.fn() } as any;

    Configuration.isDemoMode = true;
    Configuration.database.backup.enabled = false;
    Configuration.transaction.stuckTransactions.enabled = false;
    Configuration.user.deviceCheck.enabled = false;
    Configuration.server.email.enabled = false;
    Configuration.providers.syncNotifications.enabled = false;

    jobReq.fix(logger);

    expect(logger.warn).not.toHaveBeenCalled();
  });
});
