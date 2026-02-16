---
title: Total Configuration
description: Learn about the configuration capabilities of sprout.
hide:
    - footer
---

# Configuration

Sprout is designed to be flexible. You can configure the application using either a `sprout.config.yml` file placed in the application directory **OR** by using Environment Variables (best for Docker).

!!! tip "Environment Variables"

    Any setting below can be set as an environment variable by prefixing the path with `sprout_` and replacing dots `.` with underscores `_`.

    ```
    `server.port` becomes `sprout_server_port`.
    ```

## Core Settings

These are the fundamental settings required for Sprout to secure your data and start up.

| YAML Key           | Environment Variable      | Default          | Description                                                                                         |
| ------------------ | ------------------------- | ---------------- | --------------------------------------------------------------------------------------------------- |
| `encryptionKey`    | `sprout_encryptionKey`    | **Required**     | A **64-character hex string** used to encrypt database fields and cookies.                          |
| `server.port`      | `sprout_server_port`      | `8001`           | The HTTP port the backend server listens on.                                                        |
| `server.logLevels` | `sprout_server_logLevels` | `log,error,warn` | A list of log levels to output. Valid options: `verbose`, `debug`, `log`, `warn`, `error`, `fatal`. |

## Authentication

Sprout supports two authentication modes. You must choose one via `server.auth.type`.

| YAML Key           | Environment Variable      | Default | Description                                                                |
| ------------------ | ------------------------- | ------- | -------------------------------------------------------------------------- |
| `server.auth.type` | `sprout_server_auth_type` | `local` | Choose `local` for a single-user setup with a password, or `oidc` for SSO. |

### Local Auth (`type: local`)

**Only for single users**

| YAML Key                              | Environment Variable                         | Default | Description                                                |
| ------------------------------------- | -------------------------------------------- | ------- | ---------------------------------------------------------- |
| `server.auth.local.jwtExpirationTime` | `sprout_server_auth_local_jwtExpirationTime` | `30m`   | How long a login session lasts (e.g., `30m`, `24h`, `7d`). |

### OIDC Auth (`type: oidc`)

**Recommended**

| YAML Key                         | Environment Variable                    | Default | Description                                                                         |
| -------------------------------- | --------------------------------------- | ------- | ----------------------------------------------------------------------------------- |
| `server.auth.oidc.issuer`        | `sprout_server_auth_oidc_issuer`        |         | The URL of your OIDC provider (no trailing slash).                                  |
| `server.auth.oidc.clientId`      | `sprout_server_auth_oidc_clientId`      |         | The Client ID from your provider.                                                   |
| `server.auth.oidc.secret`        | `sprout_server_auth_oidc_secret`        |         | The Client Secret from your provider.                                               |
| `server.auth.oidc.allowNewUsers` | `sprout_server_auth_oidc_allowNewUsers` | `true`  | If `true`, anyone who logs in via OIDC gets a Sprout account created automatically. |

## Database & Backups

Sprout uses SQLite by default and includes a built-in backup engine.

| YAML Key                    | Environment Variable               | Default             | Description                                         |
| --------------------------- | ---------------------------------- | ------------------- | --------------------------------------------------- |
| `database.type`             | `sprout_database_type`             | `sqlite`            | The database driver to use.                         |
| `database.sqlite.database`  | `sprout_database_sqlite_database`  | `sprout.sqlite`     | The filename of the SQLite database.                |
| **Backups**                 |                                    |                     |                                                     |
| `database.backup.enabled`   | `sprout_database_backup_enabled`   | `true`              | Turn built-in backups on or off.                    |
| `database.backup.time`      | `sprout_database_backup_time`      | `0 4 * * *`         | Cron schedule for backups (Default: 4:00 AM daily). |
| `database.backup.count`     | `sprout_database_backup_count`     | `30`                | Number of rotating backups to keep.                 |
| `database.backup.directory` | `sprout_database_backup_directory` | `/backups/database` | Internal container path to store backups.           |

## Providers (Bank Sync)

Settings that control how Sprout fetches data from external financial aggregators.

| YAML Key                           | Environment Variable                      | Default     | Description                                                      |
| ---------------------------------- | ----------------------------------------- | ----------- | ---------------------------------------------------------------- |
| `providers.updateTime`             | `sprout_providers_updateTime`             | `0 8 * * *` | Cron schedule for bank syncing (Default: 8:00 AM daily).         |
| `providers.simpleFIN.lookBackDays` | `sprout_providers_simpleFIN_lookBackDays` | `14`        | How far back to check for edited/new transactions on every sync. |
| `providers.simpleFIN.rateLimit`    | `sprout_providers_simpleFIN_rateLimit`    | `24`        | Max sync attempts per day to avoid provider blocks.              |

## Automation & Logic

Fine-tune how Sprout handles data cleanup, subscriptions, and AI.

### Transactions & Holdings

| YAML Key                           | Environment Variable                      | Default       | Description                                                                        |
| ---------------------------------- | ----------------------------------------- | ------------- | ---------------------------------------------------------------------------------- |
| `transaction.stuckTransactionTime` | `sprout_transaction_stuckTransactionTime` | `0 */6 * * *` | Cron schedule to check for "stuck" pending transactions.                           |
| `transaction.stuckTransactionDays` | `sprout_transaction_stuckTransactionDays` | `7`           | Days before a pending transaction is considered "stuck" and removed.               |
| `transaction.subscriptionCount`    | `sprout_transaction_subscriptionCount`    | `3`           | Number of similar recurring charges required to identify a Subscription.           |
| `holding.cleanupRemovedHoldings`   | `sprout_holding_cleanupRemovedHoldings`   | `false`       | If `true`, deletes investment history if the holding is removed from the provider. |

### AI

| YAML Key                       | Environment Variable                  | Default                  | Description                                             |
| ------------------------------ | ------------------------------------- | ------------------------ | ------------------------------------------------------- |
| **Gemini**                     |                                       |                          |                                                         |
| `server.prompt.geminiModel`    | `sprout_server_prompt_geminiModel`    | `gemini-3-flash-preview` | The specific Google Gemini model string to use.         |
| `server.prompt.maxChatHistory` | `sprout_server_prompt_maxChatHistory` | `10`                     | Number of previous chat messages to retain for context. |

### Notifications

| YAML Key                                      | Environment Variable                                 | Default | Description                                                |
| --------------------------------------------- | ---------------------------------------------------- | ------- | ---------------------------------------------------------- |
| `server.notification.maxNotificationsPerUser` | `sprout_server_notification_maxNotificationsPerUser` | `10`    | Max alerts stored in the database per user.                |
| **Firebase**                                  |                                                      |         |                                                            |
| `server.notification.firebase.enabled`        | `sprout_server_notification_firebase_enabled`        | `false` | Enable mobile push notifications.                          |
| `server.notification.firebase.apiKey`         | `sprout_server_notification_firebase_apiKey`         |         | Firebase configuration values (from google-services.json). |
| `server.notification.firebase.privateKey`     | `sprout_server_notification_firebase_privateKey`     |         | The private key string for the service account.            |
