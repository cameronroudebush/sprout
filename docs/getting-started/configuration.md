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

| Variable                                 | Required |    Default    | Description                                                                                                                                               |
| ---------------------------------------- | :------: | :-----------: | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sprout_providers_simpleFIN_accessToken` |   Yes    |               | Your access token URL for [SimpleFIN Bridge](https://beta-bridge.simplefin.org/), which is used to connect to your bank accounts securely.                |
| `sprout_server_jwtExpirationTime`        |    No    |     `30m`     | The duration for which a login session remains valid. Examples: `24h`, `30d`.                                                                             |
| `TZ`                                     |    No    | `TZ/New_York` | Sets the timezone for the container. A [list of valid TZ values](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) is available on Wikipedia. |
| `sprout_server_auth_type`                |   Yes    |    `local`    | Set to `oidc` to enable OpenID Connect authentication                                                                                                     |
| `sprout_server_auth_oidc_issuer`         |    No    |               | The base URL of your OIDC provider (e.g., https://auth.example.com)                                                                                       |
| `sprout_server_auth_oidc_clientId`       |    No    |               | The Client ID configured in your OIDC provider.                                                                                                           |
