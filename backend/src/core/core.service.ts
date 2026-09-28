import { Account } from "@backend/account/model/account.model";
import { Configuration } from "@backend/config/core";
import type { ProviderBase } from "@backend/providers/base/core";
import { PROVIDER_LIST_TOKEN } from "@backend/providers/model/constants";
import { User } from "@backend/user/model/user.model";
import { Inject, Injectable } from "@nestjs/common";
import adminDashboard from "./assets/admin-dashboard.html?raw";

type DashboardBadge = "enabled" | "disabled" | "missing" | "informational";

interface DashboardEntry {
  value: string;
  badge?: DashboardBadge;
}

@Injectable()
export class CoreService {
  constructor(@Inject(PROVIDER_LIST_TOKEN) private readonly providers: ProviderBase[]) {}

  /** Builds dashboard data and embeds it in the admin page template. */
  async getAdminDashboard(user: User, publicUrl: string): Promise<string> {
    const data = await this.buildAdminDashboardData(user, publicUrl);
    return adminDashboard.replace("{{DASHBOARD_DATA}}", this.serializeDashboardData(data));
  }

  /** Normalizes an option and optionally marks it with a UI status badge. */
  private dashboardEntry(value: unknown, badge?: DashboardBadge): DashboardEntry {
    const formatted = Array.isArray(value) ? value.join(", ") : value;
    return { value: formatted == null || formatted === "" ? "Not configured" : String(formatted), badge };
  }

  /** Converts configuration records into ordered rows for the dashboard tables. */
  private dashboardRows(values: Record<string, unknown>) {
    return Object.entries(values).map(([key, value]) => {
      const entry = value != null && typeof value === "object" && "value" in value ? (value as DashboardEntry) : this.dashboardEntry(value);
      return { key, ...entry };
    });
  }

  /** Creates consistent enabled/disabled status rows. */
  private status(value: boolean, enabled = "Enabled", disabled = "Disabled", disabledBadge: DashboardBadge = "disabled"): DashboardEntry {
    return this.dashboardEntry(value ? enabled : disabled, value ? "enabled" : disabledBadge);
  }

  /** Prevents configuration text from escaping the inline JSON script element. */
  private serializeDashboardData(value: unknown): string {
    return JSON.stringify(value)
      .replace(/&/g, "\\u0026")
      .replace(/</g, "\\u003c")
      .replace(/>/g, "\\u003e")
      .replace(/\u2028/g, "\\u2028")
      .replace(/\u2029/g, "\\u2029");
  }

  /** Collects current-user provider connections and server configuration by dashboard section. */
  private async buildAdminDashboardData(user: User, publicUrl: string) {
    const { server, transaction, user: userConfig } = Configuration;
    const providerConfiguration = Configuration.providers;
    const backup = Configuration.database.backup;
    const transactionCleanup = transaction.stuckTransactions;
    const deviceCleanup = userConfig.deviceCheck;
    const email = server.email;
    const prompt = server.prompt;
    const activePrompt = prompt.type === "gemini" ? prompt.gemini : prompt.openCode;
    const retention = backup.gfs
      ? `${backup.gfs.dailyCount} daily, ${backup.gfs.weeklyCount} weekly, ${backup.gfs.monthlyCount} monthly, ${backup.gfs.quarterlyCount} quarterly, ${backup.gfs.yearlyCount} yearly`
      : "Default retention policy";

    // Omit OIDC settings entirely when another authentication strategy is active.
    const oidc =
      server.auth.type === "oidc"
        ? this.dashboardRows({
            Status: this.dashboardEntry("Active", "enabled"),
            Issuer: server.auth.oidc.issuer,
            "Client ID": server.auth.oidc.clientId,
            "Client secret": this.dashboardEntry(server.auth.oidc.secret ? "Configured" : "Missing", server.auth.oidc.secret ? "enabled" : "missing"),
            "New user registration": this.status(server.auth.oidc.allowNewUsers, "Allowed", "Disabled"),
            Scopes: server.auth.oidc.scopes,
          })
        : null;

    return {
      publicUrl,
      serverDetails: this.dashboardRows({
        "Public URL": publicUrl,
        "Application version": Configuration.version,
        "Runtime mode": Configuration.isDemoMode ? "Demo" : Configuration.isDevBuild ? "Development" : "Production",
        "Authentication mode": server.auth.type,
        "Local session lifetime": server.auth.local?.jwtExpirationTime,
        "Log levels": server.logLevels,
        "Database engine": Configuration.database.type,
      }),
      cleanupJobs: this.dashboardRows({
        "Stuck transaction cleanup": this.status(transactionCleanup.enabled),
        "Cleanup schedule": transactionCleanup.time,
        "Transaction age threshold": `${transactionCleanup.days} days`,
        "Inactive device cleanup": this.status(deviceCleanup.enabled),
        "Device cleanup schedule": deviceCleanup.time,
        "Device age threshold": `${deviceCleanup.days} days`,
      }),
      backgroundJobs: this.dashboardRows({
        "Exchange rate refresh": server.exchangeRate.time,
        "Post-sync processing": providerConfiguration.postSyncTime,
        "Sync notifications": this.status(providerConfiguration.syncNotifications.enabled),
        "Failed job retry delay": server.jobs?.autoRetryTime != null ? `${server.jobs.autoRetryTime} minutes` : undefined,
      }),
      rateLimits: this.dashboardRows({
        "Request limit": `${server.rateLimit.limit} requests`,
        "Rate limit window": `${server.rateLimit.ttl / 1000} seconds`,
      }),
      email: this.dashboardRows({
        Delivery: this.status(email.enabled),
        "Weekly update schedule": email.sendTime,
        "From address": email.from,
        "Mail host": email.host,
        "Mail port": email.port,
        "Secure transport": this.status(email.secure),
        "SMTP credentials": this.status(Boolean(email.user && email.pass), "Configured", "Missing", "missing"),
      }),
      prompt: this.dashboardRows({
        Provider: prompt.type,
        Service: this.status(Boolean(activePrompt?.key), "Configured", "Missing API key", "missing"),
        "Conversation model": activePrompt?.chatModel,
        "Overview model": activePrompt?.overviewModel,
        "Maximum chat history": prompt.maxChatHistory,
      }),
      oidc,
      providers: await this.getProviderStatus(user),
      backups: {
        enabled: backup.enabled,
        settings: this.dashboardRows({
          "Backup job": this.status(backup.enabled),
          Schedule: backup.time,
          "Retention policy": retention,
        }),
      },
    };
  }

  private async getProviderStatus(user: User) {
    return Promise.all(
      this.providers.map(async (provider) => {
        const appConfiguration = provider.getAppConfiguration();
        const [available, connections] = await Promise.all([
          appConfiguration.enabled ? provider.isAvailable(user) : false,
          // This dashboard count intentionally spans all users; readiness remains current-user-specific.
          Account.count({ where: { provider: provider.config.dbType } }),
        ]);

        return {
          name: provider.config.name,
          enabled: appConfiguration.enabled,
          configured: available,
          setupStatus: !appConfiguration.enabled ? "Disabled by server configuration" : available ? "Available" : "Unavailable",
          syncFrequency: appConfiguration.syncFrequency || "Not configured",
          connections,
        };
      }),
    );
  }
}
