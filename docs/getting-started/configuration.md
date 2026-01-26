---
hide:
    - toc
title: Quick Configuration
description: Learn about some of the configuration options available to Sprout.
---

<style>
.md-content__inner table td:first-child,
.md-content__inner table td:nth-child(3) {
  white-space: nowrap;
}
</style>

# Configuration

Sprout is configured using environment variables passed to the Docker container at startup.

For a complete list of all available options, please see the **[Advanced Configuration](../developer/configuration.md)** guide.

| Variable                                     | Required |    Default    | Description                                                                                                                                               |
| -------------------------------------------- | :------: | :-----------: | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sprout_encryptionKey`                       |   Yes    |               | A 64-character hex string used to encrypt sensitive database fields. See [generating an encryption key](#generating-an-encryption-key) below.             |
| `TZ`                                         |    No    | `TZ/New_York` | Sets the timezone for the container. A [list of valid TZ values](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) is available on Wikipedia. |
| `sprout_server_auth_type`                    |   Yes    |    `local`    | Set to `oidc` to enable OpenID Connect authentication                                                                                                     |
| `sprout_server_auth_oidc_issuer`             |    No    |               | The base URL of your OIDC provider (e.g., https://auth.example.com)                                                                                       |
| `sprout_server_auth_oidc_clientId`           |    No    |               | The Client ID configured in your OIDC provider.                                                                                                           |
| `sprout_server_auth_oidc_secret`             |    No    |               | The secret string used to generate the private client hash. See [auth](./auth.md#configuration) for more info                                             |
| `sprout_server_auth_local_jwtExpirationTime` |    No    |     `30m`     | The duration for which a login session remains valid for the local authentication strategy. Examples: `24h`, `30d`.                                       |

# Generating an Encryption Key

Sprout uses `AES-256-GCM` encryption to protect various fields within the database, as well as cookie encryption. You must provide a valid `32-byte` key represented as a `64-character` hexadecimal string.

One complete, you can either place it in your [`configuration.yml`](../developer/configuration.md) file or use the environment variable listed above.

You can generate this key using one of the methods below.

## Option 1: Automatic Generation (Easiest)

If you start Sprout without providing an encryption key, the application will generate a secure random key for you, print it to the logs, and then exit (or fail to start).

Check the logs of the container and look for the following info:

```
Error: An encryption key must be specified for Sprout to start and must be exactly 32 characters. See the configuration guide for more info.
Here is a randomly generated key you might want to use: RANDOM_KEY_HERE
```

## Option 2: Linux / macOS

```bash
openssl rand -hex 32
```

## Option 3: Windows (PowerShell)

```powershell
-join ((1..32) | ForEach-Object { "{0:x2}" -f (Get-Random -Min 0 -Max 256) })
```
