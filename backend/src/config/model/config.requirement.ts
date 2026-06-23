import { Configuration } from "@backend/config/core";
import { EncryptionTransformer } from "@backend/core/decorator/encryption.decorator";
import { SproutLogger } from "@backend/core/logger";
import { BaseProviderConfig } from "@backend/providers/base/config";

/** Defines a discrete cross-property configuration requirement rule */
export interface ConfigurationRequirement {
  name: string;
  /** If the app should exit on a failure of validation. Makes it so fix is not required. */
  fatal?: boolean;
  /** Returns true if the configuration structure passes the validation rule */
  validate: () => boolean;
  /** Executed when validate returns false. Corrects the in-memory state and handles logging. */
  fix: (logger: SproutLogger) => void;
}

/** Defines configuration requirements that the app will warn/fail on during startup */
export const CONFIGURATION_REQUIREMENTS: ConfigurationRequirement[] = [
  {
    name: "Database Encryption Key Validation",
    fatal: true,
    validate: () => {
      const key = Configuration.encryptionKey;
      return !!(key && key.length / 2 === EncryptionTransformer.REQUIRED_KEY_LENGTH);
    },
    fix: (logger) => {
      logger.error(
        `An encryption key must be specified for Sprout to start and must be exactly ${EncryptionTransformer.REQUIRED_KEY_LENGTH} bytes (${EncryptionTransformer.REQUIRED_KEY_LENGTH * 2} hex characters). See the configuration guide for more info.\n` +
          `Here is a randomly generated key you might want to use: ${EncryptionTransformer.generateRandomEncryptionKey()}`,
      );
    },
  },
  {
    name: "Public Application URL Presence Check",
    validate: () => {
      return !!Configuration.server?.publicUrl?.trim();
    },
    fix: (logger) => {
      logger.warn(
        `\n---------------------------------------------------\n` +
          `No publicUrl configured\n` +
          `---------------------------------------------------\n` +
          `Sprout will attempt to dynamically resolve the application URL from \n` +
          `incoming HTTP headers. If you expose Sprout to the internet, this is\n` +
          `a high-risk security vulnerability.\n\n` +
          `Please set sprout.server.publicUrl in your config file or environment variable.\n` +
          `---------------------------------------------------`,
      );
    },
  },
  {
    name: "Demo Mode Auth Restrictions",
    validate: () => !(Configuration.isDemoMode && Configuration.server?.auth?.type === "oidc"),
    fix: (logger) => {
      logger.error("Configuration Conflict: OIDC authentication cannot be enabled while running in Demo Mode. Defaulting auth mode to 'local'.");
      Configuration.server.auth.type = "local";
    },
  },
  {
    name: "Demo Mode Provider Restrictions",
    validate: () => {
      if (!Configuration.isDemoMode) return true;
      return !Object.values(Configuration.providers).some((provider: any) => provider instanceof BaseProviderConfig && provider.enabled === true);
    },
    fix: (logger) => {
      for (const [providerKey, provider] of Object.entries(Configuration.providers)) {
        if (provider instanceof BaseProviderConfig && provider.enabled === true) {
          logger.warn(`Configuration Restricton: External provider "${providerKey}" cannot be enabled in Demo Mode. Force disabling background syncs.`);
          provider.enabled = false;
        }
      }
    },
  },
  {
    name: "Demo Mode Job Restrictions",
    validate: () => {
      if (!Configuration.isDemoMode) return true;
      return (
        !Configuration.database.backup.enabled &&
        !Configuration.transaction.stuckTransactions.enabled &&
        !Configuration.user.deviceCheck.enabled &&
        !Configuration.server.email.enabled &&
        !Configuration.providers.syncNotifications.enabled
      );
    },
    fix: (logger) => {
      const features = {
        "Database Backup": Configuration.database.backup,
        "Stuck Transactions": Configuration.transaction.stuckTransactions,
        "Device Integrity Check": Configuration.user.deviceCheck,
        "Email Notifications": Configuration.server.email,
        "Sync Notifications": Configuration.providers.syncNotifications,
      };

      for (const [name, config] of Object.entries(features))
        if (config?.enabled) {
          logger.warn(`Configuration Restriction: "${name}" jobs cannot run in Demo Mode. Force disabling.`);
          config.enabled = false;
        }
    },
  },
];
