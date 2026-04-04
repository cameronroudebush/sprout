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

    You can also use comma separated lists for array values like so:
    ```
    sprout_server_logLevels=verbose,debug,error
    ```

## Core Settings

These are the fundamental settings required for Sprout to secure your data and start up.

| YAML Key                    | Environment Variable               | Default          | Description                                                                                         |
| --------------------------- | ---------------------------------- | ---------------- | --------------------------------------------------------------------------------------------------- |
| `encryptionKey`             | `sprout_encryptionKey`             | **Required**     | A **64-character hex string** used to encrypt database fields and cookies.                          |
| `server.port`               | `sprout_server_port`               | `8001`           | The HTTP port the backend server listens on.                                                        |
| `server.logLevels`          | `sprout_server_logLevels`          | `log,error,warn` | A list of log levels to output. Valid options: `verbose`, `debug`, `log`, `warn`, `error`, `fatal`. |
| **Rate limits**             |                                    |                  |                                                                                                     |
| `server.rateLimit.ttl`      | `sprout_server_rateLimit_ttl`      | `60000`          | How long the limit window is.                                                                       |
| `server.rateLimit.limit`    | `sprout_server_rateLimit_limit`    | `1000`           | How many requests we can have in the limit window.                                                  |
| **Jobs**                    |                                    |                  |                                                                                                     |
| `server.jobs.autoRetryTime` | `sprout_server_jobs_autoRetryTime` | `60`             | How many minutes to wait to re-try failed jobs automatically.                                       |

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
| **Sqlite**                  |                                    |                     |                                                     |
| `database.sqlite.database`  | `sprout_database_sqlite_database`  | `sprout.sqlite`     | The filename of the SQLite database.                |
| **Backups**                 |                                    |                     |                                                     |
| `database.backup.enabled`   | `sprout_database_backup_enabled`   | `true`              | Turn built-in backups on or off.                    |
| `database.backup.time`      | `sprout_database_backup_time`      | `0 4 * * *`         | Cron schedule for backups (Default: 4:00 AM daily). |
| `database.backup.count`     | `sprout_database_backup_count`     | `30`                | Number of rotating backups to keep.                 |
| `database.backup.directory` | `sprout_database_backup_directory` | `/backups/database` | Internal container path to store backups.           |

## Providers (Bank Sync)

Settings that control how Sprout fetches data from external financial aggregators.

| YAML Key                            | Environment Variable                       | Default                        | Description                                                                                                                                   |
| ----------------------------------- | ------------------------------------------ | ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `providers.lookBackDays`            | `sprout_providers_lookBackDays`            | `14`                           | How many days to look back for transactional data across all providers.                                                                       |
| **SimpleFIN**                       |                                            |                                |                                                                                                                                               |
| `providers.simpleFIN.syncFrequency` | `sprout_providers_simpleFIN_syncFrequency` | `0 6 * * 0`                    | How often to update this provider. Default is daily at 6am.                                                                                   |
| `providers.simpleFIN.rateLimit`     | `sprout_providers_simpleFIN_rateLimit`     | `24`                           | How many API calls we allow per day, per user, for this provider.                                                                             |
| **Zillow**                          |                                            |                                |                                                                                                                                               |
| `providers.zillow.syncFrequency`    | `sprout_providers_zillow_syncFrequency`    | `0 6 * * 0`                    | How often to update this provider. Default is daily at 6am.                                                                                   |
| `providers.zillow.rateLimit`        | `sprout_providers_zillow_rateLimit`        | `10`                           | How many API calls we allow per day, per user, for this provider.                                                                             |
| **Plaid**                           |                                            |                                |                                                                                                                                               |
| `providers.plaid.syncFrequency`     | `sprout_providers_plaid_syncFrequency`     | `0 */6 * * *`                  | How often to update this provider. Default is to run every 6 hours, starting at 6am.                                                          |
| `providers.plaid.rateLimit`         | `sprout_providers_plaid_rateLimit`         | `100`                          | How many API calls we allow per day, per user, for this provider.                                                                             |
| `providers.plaid.environment`       | `sprout_providers_plaid_environment`       | `https://production.plaid.com` | The mode that we are searching for data on for our clientId and secret. One of: [`https://sandbox.plaid.com`, `https://production.plaid.com`] |
| `providers.plaid.clientId`          | `sprout_providers_plaid_clientId`          |                                | The client Id for your plaid implementation.                                                                                                  |
| `providers.plaid.secret`            | `sprout_providers_plaid_secret`            |                                | The secret for authenticating with your plaid instance. **DO NOT SHARE THIS**.                                                                |

## Transactions

| YAML Key                           | Environment Variable                      | Default       | Description                                                              |
| ---------------------------------- | ----------------------------------------- | ------------- | ------------------------------------------------------------------------ |
| `transaction.stuckTransactionTime` | `sprout_transaction_stuckTransactionTime` | `0 */6 * * *` | Cron schedule to check for "stuck" pending transactions.                 |
| `transaction.stuckTransactionDays` | `sprout_transaction_stuckTransactionDays` | `7`           | Days before a pending transaction is considered "stuck" and removed.     |
| `transaction.subscriptionCount`    | `sprout_transaction_subscriptionCount`    | `3`           | Number of similar recurring charges required to identify a Subscription. |

## Holdings

| YAML Key                         | Environment Variable                    | Default | Description                                                                        |
| -------------------------------- | --------------------------------------- | ------- | ---------------------------------------------------------------------------------- |
| `holding.cleanupRemovedHoldings` | `sprout_holding_cleanupRemovedHoldings` | `false` | If `true`, deletes investment history if the holding is removed from the provider. |

## AI

| YAML Key                       | Environment Variable                  | Default                  | Description                                                                                                         |
| ------------------------------ | ------------------------------------- | ------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| `server.prompt.maxChatHistory` | `sprout_server_prompt_maxChatHistory` | `10`                     | Number of previous chat messages to retain for context.                                                             |
| `server.prompt.type`           | `sprout_server_prompt_type`           | `gemini`                 | The LLM provider to use. One of: [`gemini`].                                                                        |
| **Gemini**                     |                                       |                          |                                                                                                                     |
| `server.prompt.gemini.model`   | `sprout_server_prompt_gemini_model`   | `gemini-3-flash-preview` | The specific Google Gemini model string to use.                                                                     |
| `server.prompt.gemini.key`     | `sprout_server_prompt_gemini_key`     |                          | **Optional.** A global key to use to authenticate to gemini. If given, users will not be able to provide their own. |

## Notifications

| YAML Key                                      | Environment Variable                                 | Default | Description                                                |
| --------------------------------------------- | ---------------------------------------------------- | ------- | ---------------------------------------------------------- |
| `server.notification.maxNotificationsPerUser` | `sprout_server_notification_maxNotificationsPerUser` | `10`    | Max alerts stored in the database per user.                |
| **Firebase**                                  |                                                      |         |                                                            |
| `server.notification.firebase.enabled`        | `sprout_server_notification_firebase_enabled`        | `false` | Enable mobile push notifications.                          |
| `server.notification.firebase.apiKey`         | `sprout_server_notification_firebase_apiKey`         |         | Firebase configuration values (from google-services.json). |
| `server.notification.firebase.projectNumber`  | `sprout_server_notification_firebase_projectNumber`  |         | Firebase configuration values (from google-services.json). |
| `server.notification.firebase.projectId`      | `sprout_server_notification_firebase_projectId`      |         | Firebase configuration values (from google-services.json). |
| `server.notification.firebase.clientEmail`    | `sprout_server_notification_firebase_clientEmail`    |         | Firebase configuration values (from google-services.json). |
| `server.notification.firebase.privateKey`     | `sprout_server_notification_firebase_privateKey`     |         | The private key string for the service account.            |

## User

| YAML Key                      | Environment Variable                 | Default       | Description                                                    |
| ----------------------------- | ------------------------------------ | ------------- | -------------------------------------------------------------- |
| `server.user.deviceCheckTime` | `sprout_server_user_deviceCheckTime` | `0 */6 * * *` | When to check for user devices that we haven't seen in awhile. |
| `server.user.days`            | `sprout_server_user_days`            | `7`           | How many days it takes for a device to be considered stuck.    |
