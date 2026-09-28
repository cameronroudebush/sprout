import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { Account } from "@backend/account/model/account.model.js";
import { Configuration } from "@backend/config/core.js";
import type { ProviderBase } from "@backend/providers/base/core.js";
import { ProviderType } from "@backend/providers/base/provider.type.js";
import { TestEntities } from "@backend/test/entities.js";
import { CoreService } from "@backend/core/core.service.js";

function extractDashboardData(html: string) {
  const match = html.match(/<script id="dashboard-data" type="application\/json">\s*([\s\S]*?)\s*<\/script>/);
  if (!match?.[1]) throw new Error("Dashboard data not found in response.");
  return JSON.parse(match[1]);
}

function mockProvider(name: string, dbType: ProviderType, enabled: boolean, available: boolean, syncFrequency = "0 7 * * *"): ProviderBase {
  return {
    config: { name, dbType },
    getAppConfiguration: () => ({ enabled, syncFrequency }),
    isAvailable: vi.fn().mockResolvedValue(available),
  } as unknown as ProviderBase;
}

describe("CoreService", () => {
  let service: CoreService;

  beforeEach(() => {
    vi.clearAllMocks();
    service = new CoreService([]);
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("shows current-user provider setup and all-user account totals", async () => {
    const countSpy = vi.spyOn(Account, "count").mockResolvedValue(2);
    const user = TestEntities.adminUser;
    const providers = [
      mockProvider("SimpleFIN", ProviderType.simpleFin, true, true),
      mockProvider("Plaid", ProviderType.plaid, true, false),
      mockProvider("SnapTrade", ProviderType.snapTrade, false, false),
      mockProvider("Coinbase", ProviderType.coinbase, true, false),
      mockProvider("Zillow", ProviderType.zillow, true, true),
      mockProvider("Future provider", "future-provider" as ProviderType, true, true, ""),
    ];
    service = new CoreService(providers);
    const html = await service.getAdminDashboard(user, "https://sprout.example");
    const data = extractDashboardData(html);

    expect(data.publicUrl).toBe("https://sprout.example");
    expect(data.oidc).toBeNull();
    expect(data.serverDetails).toContainEqual({ key: "Authentication mode", value: "local" });
    expect(data.cleanupJobs.find((entry) => entry.key === "Stuck transaction cleanup")).toMatchObject({ value: "Enabled", badge: "enabled" });
    expect(data.prompt.find((entry) => entry.key === "Service")).toMatchObject({ value: "Configured", badge: "enabled" });
    expect(data.providers).toHaveLength(providers.length);
    expect(data.providers.find((entry) => entry.name === "SimpleFIN")).toMatchObject({ configured: true, connections: 2 });
    expect(data.providers.find((entry) => entry.name === "Future provider")).toMatchObject({
      enabled: true,
      configured: true,
      connections: 2,
      syncFrequency: "Not configured",
    });
    expect(data.providers.find((entry) => entry.name === "SnapTrade").setupStatus).toBe("Disabled by server configuration");
    expect(countSpy).toHaveBeenCalledTimes(providers.length);
    expect(countSpy).toHaveBeenCalledWith({ where: { provider: ProviderType.simpleFin } });
    expect(providers[0]!.isAvailable).toHaveBeenCalledWith(user);
    expect(html).not.toContain("identity.provider.local");
    expect(html).toContain('if (property === "href")');
    expect(html).toContain("probe.onerror = useFallback");
    expect(html).toContain("https://media.githubusercontent.com/media/cameronroudebush/sprout/master/frontend/assets/icon/favicon-bg.png");
  });

  it("renders OIDC details, missing configuration, backup fallback, and safely escaped URLs", async () => {
    const countSpy = vi.spyOn(Account, "count").mockResolvedValue(0);
    const server = Configuration.server as any;
    const backup = Configuration.database.backup as any;
    const transactionCleanup = Configuration.transaction.stuckTransactions;
    const deviceCleanup = Configuration.user.deviceCheck;
    const providerList = [
      mockProvider("SimpleFIN", ProviderType.simpleFin, false, false),
      mockProvider("Plaid", ProviderType.plaid, false, false),
      mockProvider("SnapTrade", ProviderType.snapTrade, true, true),
      mockProvider("Coinbase", ProviderType.coinbase, true, true),
      mockProvider("Zillow", ProviderType.zillow, true, true),
    ];
    service = new CoreService(providerList);
    const serverEmail = server.email;
    const user = TestEntities.adminUser;
    const originals = {
      authType: server.auth.type,
      oidc: { ...server.auth.oidc, scopes: server.auth.oidc.scopes?.slice() },
      promptType: server.prompt.type,
      openCode: { ...server.prompt.openCode },
      jobs: server.jobs,
      demoMode: Configuration.isDemoMode,
      devBuild: Configuration.isDevBuild,
      backupEnabled: backup.enabled,
      backupGfs: backup.gfs,
      transactionEnabled: transactionCleanup.enabled,
      deviceEnabled: deviceCleanup.enabled,
      email: { enabled: serverEmail.enabled, user: serverEmail.user, pass: serverEmail.pass },
      simpleFinToken: user.config.simpleFinToken,
      coinbaseApiKey: user.config.coinbaseApiKey,
      coinbaseApiKeyName: user.config.coinbaseApiKeyName,
    };

    try {
      server.auth.type = "oidc";
      Object.assign(server.auth.oidc, {
        issuer: "https://identity.example/<issuer>&tenant",
        clientId: "sprout-client",
        secret: "",
        allowNewUsers: false,
        scopes: ["openid", "profile"],
      });
      server.prompt.type = "opencode-go";
      Object.assign(server.prompt.openCode, {
        key: "configured-key",
        chatModel: "chat-model",
        overviewModel: "overview-model",
      });
      server.jobs = { autoRetryTime: 15 };
      backup.enabled = false;
      backup.gfs = undefined;
      transactionCleanup.enabled = false;
      deviceCleanup.enabled = false;
      server.email.enabled = false;
      Configuration.isDemoMode = true;
      Configuration.isDevBuild = false;
      user.config.simpleFinToken = "";
      user.config.coinbaseApiKey = "user-key";
      user.config.coinbaseApiKeyName = "user-key-name";

      const publicUrl = "https://sprout.example/?q=<x>&line=\u2028\u2029";
      const html = await service.getAdminDashboard(user, publicUrl);
      const data = extractDashboardData(html);

      expect(data.publicUrl).toBe(publicUrl);
      expect(data.oidc).not.toBeNull();
      expect(data.oidc.find((entry) => entry.key === "Client secret")).toMatchObject({ value: "Missing", badge: "missing" });
      expect(data.oidc.find((entry) => entry.key === "New user registration")).toMatchObject({ value: "Disabled", badge: "disabled" });
      expect(data.serverDetails.find((entry) => entry.key === "Runtime mode").value).toBe("Demo");
      expect(data.prompt.find((entry) => entry.key === "Conversation model").value).toBe("chat-model");
      expect(data.backgroundJobs.find((entry) => entry.key === "Failed job retry delay").value).toBe("15 minutes");
      expect(data.cleanupJobs.find((entry) => entry.key === "Stuck transaction cleanup").badge).toBe("disabled");
      expect(data.email.find((entry) => entry.key === "Delivery").badge).toBe("disabled");
      expect(data.providers.find((entry) => entry.name === "SimpleFIN").enabled).toBe(false);
      expect(data.providers.find((entry) => entry.name === "SimpleFIN").configured).toBe(false);
      expect(data.providers.find((entry) => entry.name === "Coinbase").configured).toBe(true);
      expect(data.backups.settings.find((entry) => entry.key === "Retention policy").value).toBe("Default retention policy");
      expect(data.backups.enabled).toBe(false);
      expect(html).toContain("\\u0026");
      expect(html).toContain("\\u003c");
      expect(html).toContain("\\u003e");
      expect(html).toContain("\\u2028");
      expect(html).toContain("\\u2029");
      expect(html).not.toContain("do-not-render-this-secret");

      server.auth.oidc.secret = "configured-secret";
      server.auth.oidc.allowNewUsers = true;
      server.email.user = "smtp-user";
      server.email.pass = "smtp-password";
      Configuration.isDemoMode = false;
      Configuration.isDevBuild = true;
      const configuredHtml = await service.getAdminDashboard(user, "https://sprout.example");
      const configuredData = extractDashboardData(configuredHtml);
      expect(configuredData.serverDetails.find((entry) => entry.key === "Runtime mode").value).toBe("Development");
      expect(configuredData.oidc.find((entry) => entry.key === "Client secret")).toMatchObject({ value: "Configured", badge: "enabled" });
      expect(configuredData.oidc.find((entry) => entry.key === "New user registration")).toMatchObject({ value: "Allowed", badge: "enabled" });
      expect(configuredData.email.find((entry) => entry.key === "SMTP credentials")).toMatchObject({ value: "Configured", badge: "enabled" });
      expect(configuredData.providers.find((entry) => entry.name === "Plaid").configured).toBe(false);
      expect(configuredData.providers.find((entry) => entry.name === "SnapTrade").configured).toBe(true);
      for (const secret of ["configured-secret", "configured-key", "smtp-password", "smtp-user", "user-key", "user-key-name"]) {
        expect(configuredHtml).not.toContain(secret);
      }
      expect(countSpy).toHaveBeenCalledTimes(10);
    } finally {
      server.auth.type = originals.authType;
      Object.assign(server.auth.oidc, originals.oidc);
      server.prompt.type = originals.promptType;
      Object.assign(server.prompt.openCode, originals.openCode);
      server.jobs = originals.jobs;
      Configuration.isDemoMode = originals.demoMode;
      Configuration.isDevBuild = originals.devBuild;
      backup.enabled = originals.backupEnabled;
      backup.gfs = originals.backupGfs;
      transactionCleanup.enabled = originals.transactionEnabled;
      deviceCleanup.enabled = originals.deviceEnabled;
      serverEmail.enabled = originals.email.enabled;
      serverEmail.user = originals.email.user;
      serverEmail.pass = originals.email.pass;
      user.config.simpleFinToken = originals.simpleFinToken;
      user.config.coinbaseApiKey = originals.coinbaseApiKey;
      user.config.coinbaseApiKeyName = originals.coinbaseApiKeyName;
    }
  });
});
