---
title: Total Configuration
description: Learn about the configuration capabilities of sprout.
hide:
    - footer
---

# Configuration

The configuration file, `sprout.config.yml`, is generated dynamically and placed next to the executable inside the container. Below are the available options with definitions.

## Full Configuration

```yaml linenums="1" title="sprout.config.yml"
# The encryption key to protect certain content within sprout. DO NOT LOSE THIS.
encryptionKey:

# Configuration for the various providers
providers:
    # How often to perform data queries for data from providers. Default is once a day at 8am.
    updateTime: 0 7 * * *
    # SimpleFIN configuration: https://www.simplefin.org/
    simpleFIN:
        # This access token is acquired from SimpleFIN that allows us to authenticate and grab your data.
        # You'll need to go to this link to get one configured:
        # https://beta-bridge.simplefin.org/info/developers
        accessToken: MY-ACCESS-TOKEN
        # How many days to look back for transactional data.
        lookBackDays: 7
        # How many API calls we allow per day for this provider.
        rateLimit: 24

# Core server config options
server:
    # The port to accept backend requests on.
    port: 8001
    # The log levels we want to render content for.
    # Must be one of: [verbose, debug, log, warn, error, fatal]
    logLevels:
        - log
        - error
        - warn
    # Configuration for rate limiting of the endpoints.
    rateLimit:
        # How long the limit window is.
        ttl: 60000
        # How many requests we can have in the limit window.
        limit: 1000
    # Configuration for the various jobs.
    jobs:
        # How many minutes to wait to re-try failed jobs automatically.
        autoRetryTime: 60
    # Configuration for how we want to use authentication for this app.
    auth:
        # The type of authentication strategy we want to use.
        # local: Uses a local JWT authentication strategy where we sign JWT's with the backend. Only supports one user! Uses a randomly generated secret every startup.
        # oidc: Uses the configured OIDC authentication to use a remote provider for validation. This will support multiple users.
        # Must be one of: [local, oidc]
        type: local
        # Configuration OIDC authentication capability.
        oidc:
            # The issuer URL for who is issuing the JWT's for this OIDC. Do not include trailing slashes.
            issuer: https://auth.mydomain.com
            # The client ID of your OIDC configuration so we can verify the audience.
            clientId: sprout
        local:
            # How long JWT's should stay valid for users.
            jwtExpirationTime: 30m

# Database specific options
database:
    # Configuration for performing database backups automatically
    backup:
        # If backups should occur
        enabled: true
        # How many backups we should keep
        count: 30
        # When to backup the database. Default is once a day at 4am.
        time: 0 4 * * *
        # Where to place the backup files.
        directory: /backups/database
    # The type of database we want to use
    # Must be one of: [sqlite]
    type: sqlite
    # SQLite specific configuration options
    sqlite:
        # Database file name
        database: sprout.sqlite

# Settings specific to transactions
transaction:
    # When to check for stuck transactions. This includes things like stuck pending.
    stuckTransactionTime: 0 3 * * *
    # How many days old a transaction has to be stuck for it to be auto deleted.
    stuckTransactionDays: 7
    # How many occurrences of similar transactions counts as a subscription.
    subscriptionCount: 3

# Settings specific to holdings
holding:
    # If we should clean-up holdings from the database as we no longer find them on the provider. Warning, this will remove all history for these holdings if set to true.
    cleanupRemovedHoldings: false
```

## Environment Variables

Environment variables are supported to make it easier to not have to keep track of the config file manually. Use the prefix `sprout_` followed by the config path. Here are some common examples.

```yaml
TZ: America/New_York
sprout_server_port: 9000
sprout_encryptionKey: ${SPROUT_ENCRYPTION_KEY}
sprout_database_backup_enabled: true
```

You can see more of these examples in the [setup guide](../getting-started/configuration.md).
